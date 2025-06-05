// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/CFMMAdapter.sol";

contract CFMMAdapterTest is Test {
CFMMAdapter public adapter;
address public mockRouter = address(0xDEAD); // Replace with mock or real router

csharp
Copy
Edit
function setUp() public {
    adapter = new CFMMAdapter(mockRouter);
}

function testDummy() public {
    // You can extend this with a mocked IUniswapV2Router
    assertEq(address(adapter.router), mockRouter);
}
}