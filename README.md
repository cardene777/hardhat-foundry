# Hardhat + Foundry

## Quick Start

### Clone

```bash
git clone git@github.com:cardene777/hardhat-foundry.git
```

### Remove .git

```bash
cd hardhat-foundry
rm -rf .git
```

### Install

```bash
bun install
forge install
```

### Compile

```bash
forge build
```

- output

```bash
[⠢] Compiling...
[⠔] Compiling 47 files with 0.8.23
[⠒] Solc 0.8.23 finished in ...s
Compiler run successful!
```

### Test

```bash
forge test
```

- output

```bash
[⠢] Compiling...
[⠃] Compiling 47 files with 0.8.23
[⠑] Solc 0.8.23 finished in ...s
Compiler run successful!

No tests found in project! Forge looks for functions that starts with `test`.
```

### Deploy

```bash
npx hardhat deploy:deploy-nft --network z_kyoto --contract-name HardhatFoundryERC721 --name HardhatFoundryNft --symbol HFT
```

## Check Contract

### Install

```bash
poetry shell
poetry install
```

### Check Solc

```bash
solc-select install 0.8.23
```

- output

```bash
Installing solc '0.8.23'...
Version '0.8.23' installed.
```

### Run

```bash
slither contracts

# or

slither contracts/HardhatFoundryERC721.sol
```
