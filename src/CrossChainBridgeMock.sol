// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title CrossChainBridgeMock
/// @notice A simplified contract that simulates bridging tokens between chains.
/// @dev This is for demonstration only and does not handle real token transfers!

contract CrossChainBridgeMock {
    /// @notice Event emitted when tokens are bridged out
    event BridgedOut(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 targetChainId
    );

    /// @notice Event emitted when tokens are bridged in
    event BridgedIn(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 sourceChainId
    );

    /// @notice Simulated balances (no real tokens transferred)
    mapping(address => mapping(address => uint256)) public userBalances;

    /// @notice Deposit tokens for bridging to another chain
    /// @param token The address of the token being bridged
    /// @param amount The amount of tokens to bridge
    /// @param targetChainId The destination chain id
    function bridgeOut(
        address token,
        uint256 amount,
        uint256 targetChainId
    ) external {
        require(amount > 0, "Amount must be > 0");

        // For simplicity, we just record the balance in this mock
        userBalances[msg.sender][token] += amount;

        emit BridgedOut(msg.sender, token, amount, targetChainId);
    }

    /// @notice Finalize bridging in (simulate receiving tokens from another chain)
    /// @param user The user receiving tokens
    /// @param token The token being bridged in
    /// @param amount The amount of tokens to bridge in
    /// @param sourceChainId The source chain id
    function bridgeIn(
        address user,
        address token,
        uint256 amount,
        uint256 sourceChainId
    ) external {
        require(amount > 0, "Amount must be > 0");

        // Increase the balance of the user to simulate receiving tokens
        userBalances[user][token] += amount;

        emit BridgedIn(user, token, amount, sourceChainId);
    }
}