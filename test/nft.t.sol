// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import  "../src/nft.sol";
import {DSTest} from "../lib/ds-test/src/test.sol";



contract nftTests is Test{
    // Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    market public nftmarket;

    function setUp() public {
       vm.startPrank(address(0x1));
        nftmarket = new market();
        vm.stopPrank();
    }

    // function test_Register() public {
    //     vm.startPrank(address(0x2));
    //     nftmarket.register();
    //     bool ans = registered(address(0x2));
    //     vm.stopPrank();
    //     assertEq(ans,true );
    // }

}
