// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Test} from "forge-std/Test.sol";
import {HardhatFoundryERC721} from "../../contracts/HardhatFoundryERC721.sol";

contract setup is Test {
    HardhatFoundryERC721 public nft;
    address admin = address(1);
    address user1 = address(2);
    address user2 = address(3);
    address user3 = address(4);
    string name = "Cardene Hardhat Foundry";
    string symbol = "CHFT";

    function setUp() public {
        vm.startPrank(admin);
        nft = new HardhatFoundryERC721(
            name,
            symbol
        );

        vm.label(admin, "Admin");
        vm.label(user1, "User1");
        vm.label(user2, "User2");
        vm.label(user3, "User3");

        vm.stopPrank();
    }
}
