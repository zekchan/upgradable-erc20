// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is Test {
    address public admin = makeAddr("admin");
    address public minter = makeAddr("minter");
    address public upgrader = makeAddr("upgrader");
    address public burner = makeAddr("burner");
    address public nobody = makeAddr("nobody");
    address public proxy;
    Token public token;

    function setUp() public {
        // using OZ Upgrades.deployUUPSProxy to deploy proxy and implementation contracts for us
        proxy =
            Upgrades.deployUUPSProxy("Token.sol", abi.encodeCall(Token.initialize, (admin, minter, upgrader, burner)));
        console.log("token proxy");
        console.log(proxy);
        token = Token(proxy);
    }
    // happy paths

    function test_deployment() public {
        assertEq(token.symbol(), "MTK");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(minter), 0);
        assertEq(token.balanceOf(upgrader), 0);
        assertEq(token.balanceOf(burner), 0);
    }

    function test_mint() public {
        vm.prank(minter);
        token.mint(minter, 100);
        assertEq(token.balanceOf(minter), 100);
        assertEq(token.totalSupply(), 100);
    }

    function test_transfer() public {
        vm.prank(minter);
        token.mint(minter, 100);
        assertEq(token.balanceOf(minter), 100);
        assertEq(token.totalSupply(), 100);
        vm.prank(minter);
        token.transfer(burner, 1);
        assertEq(token.balanceOf(minter), 99);
        assertEq(token.balanceOf(burner), 1);
        assertEq(token.totalSupply(), 100);
    }

    function test_burn() public {
        vm.prank(minter);
        token.mint(burner, 1);
        assertEq(token.balanceOf(burner), 1);
        assertEq(token.totalSupply(), 1);
        assertEq(token.balanceOf(burner), 1);
        vm.prank(burner);
        token.burn(1);
        assertEq(token.totalSupply(), 0);
        assertEq(token.balanceOf(minter), 0);
        assertEq(token.balanceOf(burner), 0);
    }

    // sad paths with errors
    function test_only_minter_can_mint() public {
        vm.prank(nobody);
        vm.expectRevert();
        token.mint(nobody, 1);
    }

    function test_only_burner_can_burn() public {
        vm.prank(minter);
        token.mint(nobody, 1);
        vm.prank(nobody);
        vm.expectRevert();
        token.burn(1);
    }
}
