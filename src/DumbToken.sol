// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20BurnableUpgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import {ERC20PermitUpgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @custom:oz-upgrades-from src/Token.sol:Token
contract DumbToken is
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    AccessControlUpgradeable,
    ERC20PermitUpgradeable,
    UUPSUpgradeable
{
    function doSomething(uint256 x) public pure returns (uint256) {
        return x;
    }

    function initialize() public initializer {
        __ERC20_init("MyToken", "MTK");
        __ERC20Burnable_init();
        __AccessControl_init();
        __ERC20Permit_init("MyToken");
        __UUPSUpgradeable_init();
    }
    // this implementation allows any address to upgrade

    function _authorizeUpgrade(address newImplementation) internal override {}
    // allow anyone to mint

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
