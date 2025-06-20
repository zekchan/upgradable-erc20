// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {Token} from "../src/Token.sol";
import {DumbToken} from "../src/DumbToken.sol";

contract UpgradesTest is Test {
    address public admin = makeAddr("admin");
    address public minter = makeAddr("minter");
    address public upgrader = address(this);
    address public burner = makeAddr("burner");
    address public nobody = makeAddr("nobody");
    address public proxy;
    Token public token;

    function setUp() public {
        // using OZ Upgrades.deployUUPSProxy to deploy proxy and implementation contracts for us
        proxy =
            Upgrades.deployUUPSProxy("Token.sol", abi.encodeCall(Token.initialize, (admin, minter, upgrader, burner)));
        token = Token(proxy);
    }
    // happy paths

    function test_upgrade() public {
        Upgrades.upgradeProxy(proxy, "DumbToken.sol", "");
        assertEq(DumbToken(proxy).doSomething(1), 1);
        vm.prank(minter);
        token.mint(minter, 100);
    }
}
