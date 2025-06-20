## Upgradeble ERC20 token with access roles

# Description
# Used tools and libraries
1. *Foundry* - solidity project framework with tests and scripts. Choosen without specific reason for this project.
1. *OpenZeppelin upgradeble contract* -  industry standart solidity library, provides all neccesary contracts and utilities to comply with ERC-1967 proxy pattern. Audited, "safe". Uses magic-numbered slots all storage (ERC20 storage, proxy implementation, roles) that makes upgradability simple and safe.
