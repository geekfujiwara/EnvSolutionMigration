# EnvSolutionMigration
Power Platform 環境間のソリューション移行ツールです。
複数環境からのアンマネージドソリューションを非同期的にダウンロードし、ターゲット環境へのソリューションのインポートをPowerShell で実行します。
エクスポート用のPowerShell スクリプトとインポート用のPowerShell スクリプトを分けているので、エクスポート後、本当に移行したいソリューションのみ残してからエクポート用のPowerShell を実行することができます。

![移行元テナント (1)](https://github.com/user-attachments/assets/b796dd76-c4ef-43a3-8014-1b19226cecbd)


## ダウンロード
PowerShell スクリプトで作成されています。[エクスポート](https://github.com/geekfujiwara/EnvSolutionMigration/blob/main/Solution-export.ps1)と[インポート](https://github.com/geekfujiwara/EnvSolutionMigration/blob/main/Solution-import.ps1)をそれぞれダウンロードできます。

![image](https://github.com/user-attachments/assets/c2c0caf9-6ca9-4233-a3bd-36e6c4ddfba2)

## 事前準備

### 共通事項
* PowerShell を利用します。JSON変換を利用しますので、PowerShell v7.0以上が必要です。
* [Power Platfform CLI](https://learn.microsoft.com/ja-jp/power-platform/developer/cli/introduction?tabs=windows) を利用します。
* 事前に[Visual Studio Code](https://code.visualstudio.com/) に[Power Platform Tools](https://learn.microsoft.com/ja-jp/power-apps/developer/data-platform/tools/devtools-install) をインストールしてご利用ください。
* Power Platform 環境のシステム管理者権限が必要です。
* Auth profile は以下のように作成、名前を付けます。移行元のAuth profile は `OldAdmin` という名前にし、移行先のAuth profile は`NewAdmin` とします。

https://github.com/user-attachments/assets/3d7381f0-4c34-4034-a44e-ebef1f3817b8

### エクスポート `[Solution-export.ps1](https://github.com/geekfujiwara/EnvSolutionMigration/blob/main/Solution-export.ps1)`
* エクスポート元の環境名に[2バイト文字](https://kotobank.jp/word/2%E3%81%B0%E3%81%84%E3%81%A8%E6%96%87%E5%AD%97-3215469)が入っているとエラーになります。半角に環境名を変更してください。



### インポート `[Solution-import.ps1](https://github.com/geekfujiwara/EnvSolutionMigration/blob/main/Solution-import.ps1)`
* `$TargetEnvId` には移行先のターゲット環境の環境ID を設定します。 以下より確認できます。
1. 移行先環境の[Power Apps のMaker ポータル](https://make.powerapps.com/)に移動します。
2. 開発者リソースを開きます。 ![image](https://github.com/user-attachments/assets/a922e7cc-9c90-484e-926a-196561d71817)
3. 以下に環境IDがあります。 ![image](https://github.com/user-attachments/assets/cb98e4ad-4bb3-440e-b825-ab11e63dfaa3)


## 推奨事項

* ソリューションの数によって時間がかかりますので、Azure VM 等で実施するか、PCを電源に接続し、スリープモードを解除することを推奨します。
* PowerShell スクリプトでエクスポートを実行したら、ExportedSolutions フォルダからインポートしたいソリューションだけを残します(不要なソリューションは削除します)。

## 手順

1. `Solution-export.ps1` を実行します。対象とした環境のアンマネージドソリューションがエクスポートされます。
2. そのPowerShell スクリプトがあるフォルダに自動で作成される `ExportedSolutions` フォルダにソリューションが保存されます。ソリューションは、 `環境名_表示名.zip` という命名規則で作成されます。 ![image](https://github.com/user-attachments/assets/7656fa94-c61d-4ba3-a76c-86070079d553)

3. `ExportedSolutions` フォルダにて、移行したいソリューションファイルのみを残し、その他は削除します。
4. `Solution-import.ps1` を実行します。
5.  インポートが実行され、ターゲット環境にソリューション移行が行われます。


## ポイント
最初にエクスポートを行います。対象としたい環境をフィルターするために、条件を記載します。名称で除きたい環境を指定することができます。

```
<# エクスポート対象として除きたい環境があれば、以下のように記載 #>
$envs = $envs  | Where-Object { $_.DisplayName -notlike "*Demo*"} ## 環境名に Demo が含まれている環境は除外
$envs = $envs  | Where-Object { $_.DisplayName -notlike "*Contoso*"} ## 環境名に Contoso が含まれている環境は除外
$envs = $envs  | Where-Object { $_.DisplayName -notlike "*Office*"} ## 環境名に Office が含まれている環境は除外
$envs = $envs  | Where-Object { $_.DisplayName -notlike "*CoE*"} ## 環境名に CoE が含まれている環境は除外
$envs = $envs  | Where-Object { $_.DisplayName -notlike "*Dede*"} ## 環境名に Dede が含まれている環境は除外
$envs = $envs  | Where-Object { $_.DisplayName -notlike "*operations*"} ## 環境名に operations が含まれている環境は除外
$envs = $envs  | Where-Object { $_.DisplayName -notlike "*Copilot*"} ## 環境名に Copilot が含まれている環境は除外
$envs = $envs  | Where-Object { $_.DisplayName -notlike "*Pipeline*"} ## 環境名に Pipeline が含まれている環境は除外
$envs = $envs  | Where-Object { $_.Type -ne "Teams"} ## 環境タイプが Teams の環境は除外
```
> [!Note]
> エクスポート対象外とする環境を設定することでエクスポート時間を短縮することができます。

## 注意事項
BPF (ビジネスプロセスフロー) のプロセスはソリューションに入っているのに、テーブルがソリューションに入っていない場合、エクスポートが失敗します。テーブルも含めるようにしてください。
```
指定した理由: Failed to export Business Process “KB-BPF” because solution does not include corresponding Business Process entity “mskk_kbbpf”. If this is a newly created Business Process in Draft state, activate it once to generate the Business Process entity and include it in the solution. For more information, see http://support.microsoft.com/kb/4337537.
Microsoft PowerPlatform CLI
バージョン: 1.35.1+g0c2637a
オンライン ドキュメント: https://aka.ms/PowerPlatformCLI
フィードバック、提案、問題: https://github.com/microsoft/powerplatform-build-tools/discussions

エラー: The async operation completed with a statuscode of Failed.
```

このように、出力結果を注意深く確認し、正しくソリューションがエクスポート、インポートできているかを確認ください。

以上





