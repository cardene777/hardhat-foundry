// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import { HardhatFoundryERC721 } from "../../contracts/HardhatFoundryERC721.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import { Test } from "forge-std/Test.sol";
import {Setup} from "./Setup.t.sol";

contract HardhatFoundryERC721Test is Test, Setup {
    function testAdminRoles() public view {
        assertTrue(nft.hasRole(nft.DEFAULT_ADMIN_ROLE(), admin), "Admin should have default admin role");
        assertTrue(nft.hasRole(nft.PAUSER_ROLE(), admin), "Admin should have pauser role");
        assertTrue(nft.hasRole(nft.MINTER_ROLE(), admin), "Admin should have minter role");
    }

    function testFailUnauthorizedMint() public {
        vm.prank(user1);
        nft.safeMint(user1, tokenURI); // This should fail because user1 does not have MINTER_ROLE
    }

    function testSuccessfulMintAndURI() public {
        vm.prank(admin);
        nft.safeMint(user1, tokenURI);
        assertEq(nft.tokenURI(0), expectedTokenURI, "Token URI should match the provided URI");
    }

    function testFailPausedMint() public {
        vm.prank(admin);
        nft.pause();
        vm.prank(admin);
        vm.expectRevert("Pausable: paused");
        nft.safeMint(user1, tokenURI); // This should fail because contract is paused
    }

    function testUnpauseAndMint() public {
        vm.prank(admin);
        nft.pause();
        vm.prank(admin);
        nft.unpause();
        vm.prank(admin);
        nft.safeMint(user1, tokenURI); // Should succeed after unpausing
    }

    function testBurn() public {
        vm.prank(admin);
        nft.safeMint(user1, tokenURI);
        vm.prank(user1);
        nft.burn(0);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721NonexistentToken.selector,
                0
            )
        );
        nft.tokenURI(0); // This should fail because token 0 has been burned
    }

    function testSupportsInterface() public view {
        assertTrue(nft.supportsInterface(type(IERC721).interfaceId));
    }
}
