<# 注意書き
・ソリューションの数によって時間がかかりますので、Azure VM 等で実施することを推奨します。
・もう一つのPowerShell スクリプトでエクスポートを実行したら、ExportedSolutions フォルダからインポートしたいソリューションだけを残します(不要なソリューションは削除します)。
#>
<# 以下にパラメータを設定します。 #>
$TargetAdminName = "NewAdmin" ## ターゲット環境にソリューションをインポートするユーザーのAUTH PROFILE名を設定 
$TargetEnvId = "xxxxxx-xxxx-xxxx-b10e-c6bb217dc705" ## 環境IDを設定 
$AsyncMinites = 10 ##  非同期待機時間。分単位で指定。超えるとタイムアウトになる。
$ExportFolderName = "ExportedSolutions" ## ソリューション保存先のフォルダ名を指定。ps1ファイルと同じレベルに自動的にフォルダは作成される。
<# パラメータここまで。 #>

# インポート実行 
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Error.Clear()
$ExportedSoltuionDir = ".\"+ $ExportFolderName
## フォルダ内のソリューションファイルをArrayに保存
$ImportSolutions = Get-ChildItem -Path $ExportedSoltuionDir -File | Select-Object -ExpandProperty FullName
## ターゲット環境の管理者アカウントに変更する
pac auth select -n $TargetAdminName
## 対象ソリューション数をカウント
$SolutionCount = $ImportSolutions.Length
$ThisLoop = 0
## ソリューションのインポートを実行
foreach($ImportSolution in $ImportSolutions){
    $ImportSolution
    $ThisLoop++
    $CountMessage = $ThisLoop.ToString() + "/" + $SolutionCount.ToString()
    Write-Output "$CountMessage 番目のソリューションのインポートを行います。"
    $currentDateTime = Get-Date
    Write-Output "開始時の日時は $currentDateTime です"
    pac solution import --environment $TargetEnvId --path $ImportSolution --async $True --max-async-wait-time $AsyncMinites --force-overwrite $true 
    $currentDateTime = Get-Date
    Write-Output "終了時の日時は $currentDateTime です"

}
Write-Output "インポートが完了しました。インポート時に発生したエラーは以下の通りです。"
$Error
