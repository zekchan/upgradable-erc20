# Upgradable ERC20 token with access roles

### Description
 Simple ERC20 token with hardcoded TICKER and decimals.
 Source code for token itself [src/Token.sol](src/Token.sol). Mint, burn and upgrade functionality is allowed only to specified roles. Transfers to address(0) are not allowed to anyone by ERC20 OZ implementation.
 There is also "Dumb" version of that token that does not check any roles, and allows averyone do everything. Dumb version used in [script/Upgrades.sol](script/Upgrades.sol) to test upgrade functionality.
[test/Token.t.sol](test/Token.t.sol) contains some tests for mint and burn functionality
### Used tools and libraries
1. **Foundry** - solidity project framework with tests and scripts. Choosen without specific reason for this project.
1. **OpenZeppelin upgradable contract** -  industry standart solidity library, provides all neccesary contracts and utilities to comply with ERC-1967 proxy pattern. Audited, "safe". Uses magic-numbered slots for all storage (ERC20 storage, proxy implementation, roles, something else) that makes upgradability simple and safe.
1. **OpenZeppelin UUPS proxy** - actual modern version of proxy, that uses specified hardcoded slot for storing implementation, that allows to make proxy contract smaller by delegation even upgrade logic. In practice for one proxy does not make any difference (even may broke upgradability) but in large scale can save some gas and storage.