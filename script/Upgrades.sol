// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {Token} from "../src/Token.sol";
import {DumbToken} from "../src/DumbToken.sol";

uint256 constant USER_PRIVATE_KEY = 0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6; // some user
uint256 constant MINTER_PRIVATE_KEY = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d; // upgrader
uint256 constant UPGRADER_PRIVATE_KEY = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a; // upgrader

contract UpgradesScript is Script {
    // TODO: format public and private keys somehow nice
    address public admin = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // hardhat default
    address public minter = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8; // hardhat default
    address public upgrader = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC; // hardhat default
    address public burner = 0x90F79bf6EB2c4f870365E785982E1f101E93b906; // hardhat default
    address public proxy;
    Token public token;

    function run() public {
        vm.startBroadcast(USER_PRIVATE_KEY);

        // Deploy the initial implementation and proxy
        console.log("Deploying Token proxy...");
        proxy =
            Upgrades.deployUUPSProxy("Token.sol", abi.encodeCall(Token.initialize, (admin, minter, upgrader, burner)));
        token = Token(proxy);
        console.log("Token proxy deployed at:", proxy);

        vm.stopBroadcast();

        // Mint some tokens to verify initial functionality
        vm.startBroadcast(MINTER_PRIVATE_KEY);
        token.mint(minter, 1000);
        console.log("Minted 1000 tokens to minter");

        vm.stopBroadcast();

        // Upgrade to DumbToken
        console.log("Upgrading to DumbToken...");
        vm.startBroadcast(UPGRADER_PRIVATE_KEY);
        Upgrades.upgradeProxy(proxy, "DumbToken.sol", "");

        vm.stopBroadcast();
        // Verify upgrade worked
        uint256 result = DumbToken(proxy).doSomething(42);
        console.log("DumbToken.doSomething(42) returned:", result);

        // Verify token become dumb and does allow mint anyone
        token.mint(minter, 500);
        console.log("Minted 500 more tokens after upgrade");
        console.log("Token balance of minter:", token.balanceOf(minter));
    }
}
