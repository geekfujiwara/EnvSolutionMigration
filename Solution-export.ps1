<# 注意書き
・ソリューションの数によって時間がかかりますので、Azure VM 等で実施することを推奨します。
・各環境にシステム管理者権限でアクセスできるユーザーのAuth profile で行います。
・エクスポート元の環境名に2バイト文字が入っているとエラーになります。その場合、環境名を半角英数に変更、または削除してください。
・環境名にContoso, Demo...と書かれている環境はエクスポートの対象外としていますが、必要に応じて対象外としたい環境名を変更してください。 "一部の環境の除外"を確認してください。
・アンマネージドソリューションのみをエクスポートします。ソリューションに入っていないアプリやフローはエクスポートされませんので事前に入れてください。
・エクスポート後、このps1と同じディレクトリに$ExportFolderNameというフォルダが有り、その中にソリューションが含まれていますので不要なソリューションは手動で削除します。#>
<# 以下にパラメータを設定します。 #>

$SourceAdminAuthName = "OldAdmin" ## AUTH PROFILE名を設定 
$ExportFolderName = "ExportedSolutions" ## ソリューション保存先のフォルダ名を指定。ps1ファイルと同じレベルに自動的にフォルダは作成される。

<# パラメータここまで。 #>
$Error.Clear()
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ExportedSoltuionDir = ".\"+ $ExportFolderName
if (-Not (Test-Path -Path $ExportedSoltuionDir -PathType Container)) {
    # ディレクトリが存在しない場合は作成
    mkdir $ExportedSoltuionDir
    Write-Output "ディレクトリを作成しました: $ExportedSoltuionDir"
} else {
    # ディレクトリが既に存在する場合はスキップ
    Write-Output "ディレクトリは既に存在します: $ExportedSoltuionDir"
}

# エクスポート実行
## ソリューション保存用のフォルダを作成します。

## pac auth select https://learn.microsoft.com/ja-jp/power-platform/developer/cli/reference/auth#pac-auth-select
pac auth select -n $SourceAdminAuthName
$envs = pac admin list --json | ConvertFrom-Json
<# 一部の環境の除外: エクスポート対象として除きたい環境があれば、以下のように記載 #>
$envs = $envs  | Where-Object { $_.DisplayName -notlike "*Demo*"} ## 環境名に Demo が含まれている環境は除外
$envs = $envs  | Where-Object { $_.DisplayName -notlike "*Contoso*"} ## 環境名に Contoso が含まれている環境は除外
$envs = $envs  | Where-Object { $_.DisplayName -notlike "*Office*"} ## 環境名に Office が含まれている環境は除外
$envs = $envs  | Where-Object { $_.DisplayName -notlike "*CoE*"} ## 環境名に CoE が含まれている環境は除外
$envs = $envs  | Where-Object { $_.DisplayName -notlike "*Dede*"} ## 環境名に Dede が含まれている環境は除外
$envs = $envs  | Where-Object { $_.DisplayName -notlike "*operations*"} ## 環境名に operations が含まれている環境は除外
$envs = $envs  | Where-Object { $_.DisplayName -notlike "*Copilot*"} ## 環境名に Copilot が含まれている環境は除外
$envs = $envs  | Where-Object { $_.DisplayName -notlike "*Pipeline*"} ## 環境名に Pipeline が含まれている環境は除外
$envs = $envs  | Where-Object { $_.Type -ne "Teams"} ## 環境タイプが Teams の環境は除外
<# 対象環境の整理はここまで #>
Write-Output "以下の環境を対象とします: "
$envs
## 環境のアンマネージドソリューションをエクスポートします。
foreach($env in $envs) {
    ## pac solution list https://learn.microsoft.com/ja-jp/power-platform/developer/cli/reference/solution#pac-solution-list
    $solutions = pac solution list -env $env.EnvironmentId --json | ConvertFrom-Json     

    ## アンマネージドソリューションのみにフィルター
    $UnManagedSolutions = $solutions | Where-Object { $_.IsManaged -eq $False } 
    ## 既定のソリューションはフィルターして除外
    $UnManagedSolutions = $UnManagedSolutions | Where-Object { $_.FriendlyName -ne "Common Data Services Default Solution" }
    $UnManagedSolutions = $UnManagedSolutions | Where-Object { $_.SolutionUniqueName -ne "Default" }
    Write-Output "アンマネージドソリューションの一覧: "
    $UnManagedSolutions
    foreach($UnManagedSolution in $UnManagedSolutions)  {
        $ThisEnvName = $env.DisplayName
        $FriendlyName = $UnManagedSolution.FriendlyName
        $SolutionUniqueName = $UnManagedSolution.SolutionUniqueName
        $EnvironmentId = $env.EnvironmentId
        $SolutionPath = $ExportedSoltuionDir + "\" + $ThisEnvName + "_" + $FriendlyName + ".zip"
        Write-Host  "$ThisEnvName のアンマネージドソリューション: $FriendlyName"
        pac solution export --environment $EnvironmentId --path $SolutionPath --name $SolutionUniqueName --managed false --include general --async $True --overwrite $True    

    } 
}
Write-Output "エクスポートが完了しました。エクスポート時に発生したエラーは以下の通りです。"
$Error
