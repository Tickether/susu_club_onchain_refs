// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SusuClubOnchainRefs} from "../src/SusuClubOnchainRefs.sol";

contract SusuClubOnchainRefsScript is Script {
    SusuClubOnchainRefs public susuClubOnchainRefs;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        susuClubOnchainRefs = new SusuClubOnchainRefs();

        vm.stopBroadcast();
    }
}
