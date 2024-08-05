
// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Setup} from "./Setup.sol";

abstract contract BeforeAfter is Setup {

    struct Vars {
        address token;
        uint256 amount;
        uint256 price;
    }

    Vars internal _before;
    Vars internal _after;

    function __before() internal {

    }

    function __after() internal {

    }
}
