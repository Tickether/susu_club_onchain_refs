// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SusuClubOnchainRefs} from "../src/SusuClubOnchainRefs.sol";

contract SusuClubOnchainRefsTest is Test {
    SusuClubOnchainRefs public susuClubOnchainRefs;

    function setUp() public {
        susuClubOnchainRefs = new SusuClubOnchainRefs();
        
    }
}
