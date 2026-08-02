# QRNクリーンルーム独立再現プロジェクト

あなたは、既存研究のコードを移植する開発者ではなく、**論文に記載された主張を独立に検証・反証する計算物理研究者**として行動してください。

このプロジェクトの目的は、Fable 5が構築したQuantum Relational Network研究について、原実装を一切参照せず、論文だけを仕様として、Juliaによる独立実装を作成し、主要な数理的・数値的主張が再現されるかを検証することです。

## 1. 最重要原則

この作業はクリーンルーム方式で行います。

### 参照してよいもの

* このリポジトリの `papers/` または `specs/` に置かれた論文、仕様書、数式
* Juliaの公式ドキュメント
* 使用する数値計算ライブラリの公式ドキュメント
* 一般に確立された数学・物理学の教科書的知識

### 参照してはいけないもの

* 元の `Quantum-Relational-Network` リポジトリのソースコード
* 元リポジトリの `results/`、テストコード、コミット履歴、Issue、Discussion
* Fable 5が生成した中間データ
* 元実装の変数名、関数名、アルゴリズム構成
* 元実装の期待出力を転載したファイル
* 元研究のプロンプト、思考ログ、内部メモ

元リポジトリが同じマシン上に存在していても、絶対に開かないでください。ファイル検索、Git検索、全文検索、GitHub APIなどを使って探索することも禁止します。

論文中に結果数値が書かれている場合、それは最終比較には使用できますが、実装中のパラメータ調整やアルゴリズム選択には使用しないでください。

## 2. 研究姿勢

目標は論文を正しいと証明することではありません。

以下を優先してください。

1. 論文の主張を明確な検証可能命題へ分解する
2. 各命題について反例を探す
3. 論文に隠れた仮定があれば明示する
4. 数値的一致だけでなく、失敗条件と非識別条件も検証する
5. 再現できない場合、無理に一致させず失敗として記録する
6. 実装ミス、仕様不足、数値不安定性、主張の誤りを区別する
7. 「答えられない」ケースでは、推測せず棄却する

結果が論文と一致しない場合も、それ自体を重要な研究成果として扱ってください。

## 3. 独立性の要件

独立性を高めるため、次を守ってください。

* 実装言語はJuliaとする
* 元研究と異なるデータ構造、数値解法、ライブラリ構成を採用する
* 問題生成器を独自実装する
* Hamiltonian、状態、時間発展、応答測定、ホモロジー計算、採点を独立に実装する
* 小規模問題については、可能なら2種類以上の独立アルゴリズムで相互照合する
* 解析解がある場合は数値結果と比較する
* 浮動小数点精度を変えて安定性を調べる
* seed、依存関係、実行環境をすべて記録する
* 元論文の成功例だけでなく、反例・null例・非識別例を含める

外部パッケージを使う場合も、研究の中心部分を一つのブラックボックスに委ねないでください。特にグラフ復元、応答計算、ホモロジー、判定規則については、少なくとも小規模例を独自実装と照合してください。

## 4. 最初に行う文献監査

実装を始める前に、`papers/` と `specs/` の全文を読み、次のファイルを作成してください。

### `docs/claim_inventory.md`

各主張について以下を記録してください。

* claim ID
* 主張の自然言語表現
* 数式による表現
* 必要な仮定
* 入力
* 出力
* 検証方法
* 反証条件
* 数値許容誤差
* 既知定理かQRN固有主張か
* 独立再現の対象に含めるか
* 曖昧または不足している仕様

主張を少なくとも以下に分類してください。

* 解析的恒等式
* 数値アルゴリズム
* geometry readout
* factorization recovery
* interaction hypergraph recovery
* identifiability / abstention
* topology / homology
* regulator universality
* scoped toy-model result
* 自然界に関する主張

### `docs/ambiguities.md`

論文だけでは一意に実装できない箇所を列挙してください。

曖昧な点について、元コードを見て解決してはいけません。代わりに、物理的・数学的に妥当な解釈を複数提示し、それぞれを別実装として検証してください。

### `docs/replication_plan.md`

実装順序、検証順序、凍結手順、holdout設計、合否条件を記載してください。

この3文書が完成する前に、本格的な実装へ進まないでください。

## 5. 優先して独立再現する主張

論文の内容を確認したうえで、少なくとも次を検証してください。

### A. 局所応答から結合強度を復元する法則

局所部分系 (i) に正負の微小摂動を加え、部分系 (j) の短時間密度曲率差から、

[
\frac{\ddot n_j^{+}(0)-\ddot n_j^{-}(0)}{4\epsilon}
===================================================

\left|P_j H P_i\right|_F^2
]

または論文に記載された対応式が成立するか確認してください。

検証対象：

* 自由Gaussian系
* ランダムHermitian hopping
* 開放境界・周期境界
* 不均一結合
* 密度対角相互作用を持つ非Gaussian (t-V) 系
* 法則が成立しない相互作用の反例
* 摂動強度依存性
* 時間差分刻み依存性
* ノイズ感度
* 内部基底変換への不変性

有限差分だけでなく、可能なら交換子から解析的に二階微分を計算する実装も用意し、時間発展版と照合してください。

### B. 操作ネットワークから局所因子分解を復元

原始操作集合と、それらの可換・非可換関係から局所因子候補を復元してください。

検証対象：

* 3量子ビット
* qubit × qutrit
* 局所ユニタリ変換後
* ノード置換後
* 情報不足な操作集合
* 互いに非互換な複数factorization
* 非自明な中心を持つ作用素代数
* superselection sector
* fermionic parity
* ordinary commutatorとgraded commutatorの違い

復元結果は完全な基底一致ではなく、局所ユニタリ変換とノード置換を除いた同値類として評価してください。

### C. 相互作用ハイパーグラフの復元

Hamiltonianを局所部分集合 (S) ごとの成分へ分解し、

[
H=\sum_{S\subseteq V}H_S,
\qquad
w_S=|H_S|_F^2
]

に相当する相互作用次数を復元してください。

検証対象：

* on-site項
* 二体hopping
* 密度密度相互作用
* correlated hopping
* pair hopping
* 真の三体項
* null三体項
* 四体以上の項
* 局所基底変換
* 非局所基底変換
* 条件付きprobe
* coherent probe
* 符号・複素位相・磁束方向の識別可能性

観測契約によって見える量と見えない量を分離してください。

### D. 幾何・トポロジーの復元

復元した関係重みから、隣接グラフ、距離、単体複体、ホモロジーを構成してください。

検証対象：

* 1D path
* 1D cycle
* 2D torus
* cylinder
* disk
* two-hole disk
* sphere
* genus-2 surface
* 3-torus
* 3-sphere
* 3-ball
* random regular graph
* Petersen graph
* complete graph
* 分岐を持つ非多様体
* 相関が縮退して裁定不能な例

少なくとも以下を計算してください。

[
\beta_0,\beta_1,\beta_2,\beta_3
]

可能なら、clique complexとVietoris–Rips complexを独立に実装し、既知の小規模例で検証してください。

### E. 識別不能性と棄却

必ず次のケースを含めてください。

* 低温極限で情報が飽和する状態
* projector状態の同値類
* factorizationが与えられない状態
* Gaussian oracleを非Gaussian状態へ誤適用するケース
* (H) と (-H) が二階応答で区別不能なケース
* 磁束 (+\theta) と (-\theta) が密度応答だけでは区別不能なケース
* 高ノイズ
* 判定閾値の信頼区間が境界をまたぐケース
* 複数の同等なfactorizationが存在するケース

これらについて、誤った一意解を出さず、以下のいずれかを返す設計にしてください。

* `Answer`
* `EquivalenceClassOnly`
* `InsufficientObservation`
* `Abstain`
* `OutOfDomain`

## 6. 実装構成

Juliaパッケージとして構成してください。

推奨構成：

```text
Project.toml
Manifest.toml
README.md

src/
  QRNReplication.jl
  Algebra/
  States/
  Dynamics/
  Responses/
  Factorization/
  Hypergraphs/
  Geometry/
  Homology/
  Identifiability/
  Scoring/
  Reproducibility/

test/
  unit/
  analytic/
  adversarial/
  integration/
  holdout/

experiments/
  train/
  validation/
  holdout/

docs/
  claim_inventory.md
  ambiguities.md
  replication_plan.md
  derivations.md
  numerical_methods.md
  limitations.md

reports/
  environment.json
  freeze_manifest.json
  final_report.md
  machine_report.json
```

コードには型注釈、docstring、引数検査、数値例外処理を入れてください。

重要な概念を単なる `Tuple` や `Float64` で混在させず、以下のような意味付き型を使ってください。

* `DecayRate`
* `LengthScale`
* `InteractionWeight`
* `ObservationContract`
* `FactorizationResult`
* `IdentifiabilityResult`
* `TopologyCertificate`
* `AbstentionReason`

異なる意味の数値を取り違えられない設計にしてください。

## 7. 数値計算の独立性

以下を実施してください。

* dense exact diagonalization
* Krylovまたはexpm系の時間発展
* 交換子による解析的短時間微分
* 有限差分による独立照合
* 任意精度またはBigFloatによる小規模検査
* 複数の固有値solverによる比較
* condition numberの記録
* 刻み幅収束試験
* 系サイズ収束試験
* ノイズ注入試験

一致した桁数だけでなく、誤差のスケーリング則を記録してください。

## 8. 学習区画・検証区画・holdout区画

データを次の3区画に厳密分離してください。

### Train

アルゴリズム開発、バグ修正、閾値設計に使用してよい。

### Validation

原則一度だけ使用する。閾値とscorerの最終確認に使う。

### Holdout

凍結前には生成しない。seedも開示しない。結果を見て実装を修正してはいけない。

holdoutには、成功すべき問題と棄却すべき問題を両方含めてください。

目標指標：

[
\text{selective risk}=0
]

[
\text{answerable recall}\ge0.9
]

[
\text{impossibility recall}=1.0
]

ただし、論文で別の事前登録値が明示されている場合は、それを優先してください。

## 9. 凍結手順

実装と評価規則が完成したら、holdout生成前に以下を実施してください。

1. すべてのtrain / validationテストを実行
2. `Manifest.toml`を固定
3. Juliaバージョン、OS、CPU、BLAS、thread数を記録
4. scorer、閾値、棄却条件を固定
5. git commit
6. commit hashを記録
7. 全対象ファイルのSHA-256 manifestを作成
8. `reports/freeze_manifest.json`へ保存
9. その時点でコード変更を停止

凍結後にバグが判明した場合：

* 元の失敗結果を保存する
* バグ修正版は新しいexperiment IDで実行する
* 元のholdoutをfresh holdoutとして再利用しない
* 修正後は新しいholdoutを生成する

## 10. hidden holdoutの生成

holdout seedは、凍結後に初めて取得してください。

可能なら以下の方式を使います。

```text
seed = SHA256(secret || experiment_id || cell_id)
```

凍結時には `SHA256(secret)` だけを公開し、secret本体は開示しません。

holdoutを初開封するときは、次をログへ残してください。

* secret
* 事前公開されたsecret hashとの一致
* freeze commit hash
* manifest hash
* 各cellのseed
* 実行時刻
* 生の出力
* 採点結果

## 11. 原論文との比較方法

Codex版の実装・評価・holdout採点がすべて終わるまで、原研究の細かな数値結果と照合しないでください。

最終比較では、以下を区別してください。

* 定性的再現
* 定量的再現
* 許容誤差内
* 部分再現
* 再現失敗
* 仕様不足
* 原論文と異なるが数学的に妥当
* 元主張の適用範囲が狭い
* 新しい反例

一致しなかった値を、後からパラメータ調整して合わせてはいけません。

## 12. 反証テスト

論文記載の試験だけでなく、以下の敵対的試験を自ら設計してください。

* 階層的に弱い辺
* 近接辺と同程度の長距離相関
* 対称性による縮退
* 非局所ユニタリ変換
* 近接グラフを誤認しやすいregular graph
* 境界反射
* 非一様ノイズ
* 欠測
* 誤指定されたfactorization
* 不完全な操作集合
* hidden高体相互作用
* 有限差分誤差が信号と同程度になる領域
* 異なるHamiltonianが同じ観測を作る例

反例を発見した場合は、論文の主張を狭める提案をしてください。反例をテストから除外してはいけません。

## 13. 最終成果物

最終的に以下を作成してください。

### `reports/final_report.md`

次の構成にしてください。

1. Executive Summary
2. Clean-room independence statement
3. Papers and claims examined
4. Independent mathematical derivations
5. Implementation overview
6. Numerical validation
7. Fresh holdout protocol
8. Holdout results
9. Replicated claims
10. Failed or weakened claims
11. Non-identifiable regimes
12. Newly discovered counterexamples
13. Differences from the paper
14. Limitations
15. Verdict
16. Recommended next experiments

### `reports/machine_report.json`

少なくとも以下を含めてください。

```json
{
  "replication_type": "cross_model_clean_room",
  "implementation_agent": "OpenAI Codex",
  "original_research_agent": "Fable 5",
  "language": "Julia",
  "original_source_access": false,
  "original_results_access_during_implementation": false,
  "independent_generator": true,
  "independent_solver": true,
  "hidden_holdout": true,
  "shared_human_operator": true,
  "organizationally_external": false,
  "freeze_commit": "",
  "manifest_sha256": "",
  "claims_tested": [],
  "claims_replicated": [],
  "claims_failed": [],
  "claims_ambiguous": [],
  "new_counterexamples": [],
  "answerable_recall": null,
  "impossibility_recall": null,
  "selective_risk": null
}
```

### `README.md`

第三者が以下だけで再現できる手順を書いてください。

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. test/runtests.jl
julia --project=. experiments/run_train.jl
julia --project=. experiments/run_validation.jl
julia --project=. experiments/run_holdout.jl
```

実際の構成に合わせて調整してください。

## 14. 判定基準

最終判定は以下のいずれかにしてください。

### Replicated

主要な解析則、応答復元、因子分解、相互作用構造、識別不能判定が、独立実装とfresh holdoutで成立。

### Partially Replicated

主要部分は成立するが、適用範囲、精度、特定の系で差異がある。

### Not Replicated

中心主張が独立実装では成立しない。

### Inconclusive

論文仕様が不十分、数値資源不足、必要な観測契約が不明などの理由で判定不能。

成功へ誘導するために判定を緩めてはいけません。

## 15. 作業の進め方

次の順番を厳守してください。

### Phase 0：環境確認

* このリポジトリが空の独立リポジトリであることを確認
* 元リポジトリを参照していないことを記録
* Julia環境を初期化

### Phase 1：論文監査

* `claim_inventory.md`
* `ambiguities.md`
* `replication_plan.md`

を作る。

### Phase 2：解析導出

コードを書く前に、中心恒等式を独立に導出し、`docs/derivations.md`へ記録する。

### Phase 3：最小実装

小規模な解析可能系で各モジュールを検証する。

### Phase 4：独立生成器と敵対例

論文の例をコピーせず、独自分布から問題を生成する。

### Phase 5：train / validation

アルゴリズムと閾値を確定する。

### Phase 6：freeze

commit、hash、manifestを固定する。

### Phase 7：fresh holdout

凍結済みコードを変更せず、一度だけ採点する。

### Phase 8：最終報告

原論文の結果と比較し、成功・失敗・新反例をすべて公開する。

## 16. 禁止事項

* 元コードの閲覧
* 元コードの翻訳
* 元結果へ合わせたチューニング
* holdout開封後の閾値変更
* 失敗セルの削除
* 結果を見た後で「例外ケース」と再分類
* PASS条件の事後緩和
* 同じholdoutを修正版で再びfreshとして使用
* 数値的一致だけを根拠に物理法則と断定
* toy modelの成功を自然界の時空・重力へ昇格
* cross-model replicationを外部人間再現と表記
* 不明点を元コードから補完

## 17. 最終的な科学的主張の上限

この再現が成功しても、直ちに次を主張してはいけません。

* 時空が量子状態から創発した
* 重力が導出された
* Einstein方程式が得られた
* 統一場理論が完成した
* 自然界でQRNが正しい
* 外部研究者による独立再現が完了した

主張できる最大範囲は、結果に応じて次のようなものです。

> 論文仕様だけを用いたJuliaによるクリーンルーム独立実装において、特定の有限量子系と観測契約の下で、局所応答から相互作用構造、因子分解候補、幾何・トポロジー、および非識別領域を復元する主要主張が再現された。

## 18. 最初の応答

まずコードを書かず、以下を提示してください。

1. 読み込んだ論文・仕様書の一覧
2. 独立再現対象とする主要claim一覧
3. 曖昧な仕様
4. 反証を優先すべき主張
5. 実装アーキテクチャ案
6. train / validation / holdout設計案
7. 使用予定のJuliaパッケージと、それぞれを使う理由
8. 元実装からの独立性をどう保証するか
9. 作業開始時点のgit statusと環境情報

その後、`docs/claim_inventory.md`、`docs/ambiguities.md`、`docs/replication_plan.md`を作成してから実装へ進んでください。
