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

contract Token is
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    AccessControlUpgradeable,
    ERC20PermitUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant WITHDRAW_ADMIN_ROLE = keccak256("WITHDRAW_ADMIN_ROLE");

    /// @custom:storage-layout erc7201:namespace=locked.balances
    struct TokenStorage {
        mapping(address => uint256) balances;
    }

    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    /// @custom:oz-upgrades-unsafe-allow constructor
    bytes32 private constant _storageLocation = 0x328bcd7529501e9742d6c12f5f2712cc411df6c15a942f4232ff0ece51406d34; // keccak256("erc7201:namespace=locked.balances");

    function _getLockedBalancesStorage() private pure returns (TokenStorage storage $) {
        assembly {
            $.slot := _storageLocation
        }
    }

    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin, address minter, address upgrader, address burner) public initializer {
        __ERC20_init("MyToken", "MTK");
        __ERC20Burnable_init();
        __AccessControl_init();
        __ERC20Permit_init("MyToken");
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
        _grantRole(UPGRADER_ROLE, upgrader);
        _grantRole(BURNER_ROLE, burner);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}

    function burn(uint256 amount) public override onlyRole(BURNER_ROLE) {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 value) public override onlyRole(BURNER_ROLE) {
        super.burnFrom(account, value);
    }

    function lock(address account, uint256 amount) public onlyRole(WITHDRAW_ADMIN_ROLE) {
        _getLockedBalancesStorage().balances[account] += amount;
    }

    function unlock(address account, uint256 amount) public onlyRole(WITHDRAW_ADMIN_ROLE) {
        _getLockedBalancesStorage().balances[account] -= amount;
    }

    function _update(address from, address to, uint256 value) internal override {
        super._update(from, to, value);
        if (msg.sig == this.withdrawLockedBalance.selector) {
            return;
        }

        uint256 lockedBalance = _getLockedBalancesStorage().balances[from];
        uint256 currentBalance = balanceOf(from);
        if (currentBalance < lockedBalance) {
            revert("Transfer would exceed locked balance");
        }
    }

    function withdrawLockedBalance(address account, uint256 amount) public onlyRole(WITHDRAW_ADMIN_ROLE) {
        uint256 lockedBalance = _getLockedBalancesStorage().balances[account];
        if (amount > lockedBalance) {
            revert("Insufficient locked balance");
        }
        // _getLockedBalancesStorage().balances[account] = lockedBalance - amount;
        _transfer(account, msg.sender, amount);
    }
}
