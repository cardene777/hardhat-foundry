## 概要

- Slither-Actionとは、Slitherというコントラクト脆弱性診断ツールをGithubのプルリクなどで実行できるツールです。
- Github Actionsを使用して簡単に導入できるので、その手順をまとめます。

[GitHub - crytic/slither: Static Analyzer for Solidity and Vyper](https://github.com/crytic/slither?tab=readme-ov-file)

## 実装

### 前提

- 以下をもとに実装していきます。

[slither-action - GitHub Marketplace](https://github.com/marketplace/actions/slither-action)

### ディレクトリ構成

- まずディレクトリ構成は以下のようになっています。

```bash
.
├── .github # 今回はこちらを作成していきます。
│   ├── scripts
│   └── workflows
├── contract # hardhatの環境がは以下にあります。
│   ├── contracts # コントラクトが含まれるディレクトリ
│   ├── ignition
│   │   └── modules
│   ├── tasks
│   └── test
│       └── foundry
└── docs
└── slither.config.json # 今回はこちらを作成していきます。
```

### ディレクトリ作成

- ルートに「**contract**」というディレクトリが存在し、その中にhardhat + foundryの環境があります。

- ルートで以下のコマンドを実行してファイルを作成してください。

```bash
mkdir -p .github/workflows && touch .github/workflows/slither-action.yml
```

```bash
mkdir -p .github/scripts && touch .github/scripts/comment.js
```

### `slither-action.yml`

- `slither-action.yml`に以下をコピペしてください。

```yaml
name: Slither Analysis action

on:
  push:
    branches: [develop] # 開発環境のブランチ名にしてください。
  pull_request:
    branches: [develop] # 開発環境のブランチ名にしてください。
  workflow_dispatch:

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Run Slither
        uses: crytic/slither-action@v0.3.0
        id: slither
        with:
          target: "./contract" # ルートからhardhatの環境がある場所のディレクトリパスを入れてください。
          fail-on: none
          slither-args: --checklist --markdown-root ${{ github.server_url }}/${{ github.repository }}/blob/${{ github.sha }}/

      # pullrequのコメントにMarkdownでレポートを出力する設定。
      - name: Create/update checklist as PR comment
        uses: actions/github-script@v6
        if: github.event_name == 'pull_request'
        env:
          REPORT: ${{ steps.slither.outputs.stdout }}
        with:
          script: |
            const script = require('.github/scripts/comment')
            const header = '# Slither report'
            const body = process.env.REPORT
            await script({ github, context, header, body })
```

### comment.js

- comment.jsに以下をコピペしてください。
- pullrequのコメントにMarkdownでレポートを出力する設定です。

```yaml
module.exports = async ({ github, context, header, body }) => {
  const comment = [header, body].join("\n");

  const { data: comments } = await github.rest.issues.listComments({
    owner: context.repo.owner,
    repo: context.repo.repo,
    issue_number: context.payload.number,
  });

  const botComment = comments.find(
    (comment) =>
      // github-actions bot user
      comment.user.id === 41898282 && comment.body.startsWith(header)
  );

  const commentFn = botComment ? "updateComment" : "createComment";

  await github.rest.issues[commentFn]({
    owner: context.repo.owner,
    repo: context.repo.repo,
    body: comment,
    ...(botComment
      ? { comment_id: botComment.id }
      : { issue_number: context.payload.number }),
  });
};
```

### `slither.config.json`

- Slitherの設定ファイルである`slither.config.json`をルート直下に作成してください。
- 作成したら以下をコピペしてください。
- 解析不要なファイルをまとめることができます。
    - 特に`node_modules`が含まれていると大量の解析結果が出るので注意。

```yaml
{
  "filter_paths": "contracts/mocks,lib,node_modules"
}
```

### 出力

- 上記の設定をしてpullrequを作成すると以下のようにレポートが生成されます。

![Screenshot 2024-05-14 at 12 49 59](https://github.com/cardene777/hardhat-foundry/assets/61857866/d0fb263f-789c-47f3-a649-bcae6ce5f591)


## レポートの見方

### 概要

![Screenshot 2024-05-14 at 12 50 14](https://github.com/cardene777/hardhat-foundry/assets/61857866/ea612994-2328-46cf-b6fe-4000a4491b81)


- 上記のようにざっくり項目がまとめられています。
- **Informational**の部分は**Impact (影響度)**を示しており、以下のように左に行くほど危険性が高いです。

```yaml
High > Medium > Low > Informational
```

### 詳細

![Screenshot 2024-05-14 at 12 50 27](https://github.com/cardene777/hardhat-foundry/assets/61857866/ae69c115-144c-49d4-87b7-ae52d162a142)

- 先ほどの概要ともとに各項目の詳細がチェックリストでまとめられています。
- Confidenceは信頼度を示しており、Slitherによる検知の正確性や確信の度合いを示しています。
- 信頼度も**Impact (影響度)**同様以下の値があります。

```yaml
High > Medium > Low > Informational
```

## オプション機能

| キー | 説明 |
| --- | --- |
| ignore-compile | trueに設定されている場合、プロジェクトのコンパイルを試みません。デフォルトはFalseです。 |
| fail-on | 指定された重大度以上の問題をSlitherが検出した場合にアクションを失敗させます。 |
| node-version | 使用するNode.jsのバージョン。指定されていない場合は、最新バージョンが使用されます。 |
| sarif | 提供された場合、生成されるSARIFファイルのパス（リポジトリのルートからの相対パス）。 |
| slither-args | Slitherに渡す追加の引数。 |
| slither-config | Slitherの設定ファイルへのパス。デフォルトでは存在する場合./slither.config.jsonが使用されます。 |
| slither-version | 使用するslither-analyzerのバージョン。デフォルトではPyPIの最新リリースが使用されます。 |
| slither-plugins | Slitherと一緒にpipでインストールするカスタムプラグインのrequirements.txtファイル。 |
| solc-version | 使用するsolcのバージョン。このフィールドが設定されていない場合、プロジェクトのメタデータからバージョンが推測されます。 |
| target | Slitherによって分析されるプロジェクトのルートへのパス。ディレクトリまたはファイルを指定でき、デフォルトではリポジトリのルートです。 |

## 参考記事

[AIが考える脆弱なスマートコントラクト vs 脆弱性診断ツール [OpenZeppelin Defender, Slither] - Qiita](https://qiita.com/0xnatto/items/69615d32b8d19295ccb3#第２回戦slither)

[Slither Action導入時に出たエラーの対処備忘録](https://zenn.dev/pokena/scraps/66df18b17abd47)
