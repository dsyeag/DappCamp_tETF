
// // SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

interface IUniswap {
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
        path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
    );
        _swap(amounts, path, to);
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
    address from,
    address to,
    uint256 amount
    ) external returns (bool);
}

contract FundManager {
    IUniswap uniswap;

    function swapTokensForExactTokens(
        address token,
        uint amountIn,
        uint amountOutMin,
        uint deadline
    )
    external {
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = uniswap.USDC();
        IERC20(token).approve(address(uniswap), amountIn);
        uniswap.swapTokensForExactTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            deadline
        );
    }

}