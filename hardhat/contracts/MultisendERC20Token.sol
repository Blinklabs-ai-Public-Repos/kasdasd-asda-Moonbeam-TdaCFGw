// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";

/**
 * @title MultisendERC20Token
 * @dev ERC20 token with Multisend and Gasless transaction features
 * @notice This contract implements an ERC20 token with additional features like multisend and gasless transactions
 */
contract MultisendERC20Token is ERC20, ERC20Permit, Multicall {
    uint256 private immutable _maxSupply;

    /**
     * @dev Constructor that sets the name, symbol, and max supply of the token
     * @param name_ The name of the token
     * @param symbol_ The symbol of the token
     * @param maxSupply_ The maximum supply of the token
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_
    ) ERC20(name_, symbol_) ERC20Permit(name_) {
        require(maxSupply_ > 0, "MultisendERC20Token: Max supply must be greater than 0");
        _maxSupply = maxSupply_;
        _mint(msg.sender, maxSupply_);
    }

    /**
     * @dev Returns the maximum supply of the token
     * @return The maximum supply
     */
    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    /**
     * @dev Multisend function to send tokens to multiple addresses in a single transaction
     * @param recipients An array of recipient addresses
     * @param amounts An array of amounts to send to each recipient
     * @notice This function allows sending tokens to multiple recipients in one transaction
     */
    function multisend(address[] memory recipients, uint256[] memory amounts) public {
        require(recipients.length == amounts.length, "MultisendERC20Token: Recipients and amounts arrays must have the same length");
        require(recipients.length > 0, "MultisendERC20Token: Must provide at least one recipient");
        
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            require(amounts[i] > 0, "MultisendERC20Token: Amount must be greater than 0");
            totalAmount += amounts[i];
        }
        
        require(balanceOf(msg.sender) >= totalAmount, "MultisendERC20Token: Insufficient balance for multisend");

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "MultisendERC20Token: Cannot send to zero address");
            _transfer(msg.sender, recipients[i], amounts[i]);
        }
    }

    /**
     * @dev Override of the _mint function to enforce the max supply limit
     * @param account The account to mint tokens to
     * @param amount The amount of tokens to mint
     */
    function _mint(address account, uint256 amount) internal virtual override {
        require(totalSupply() + amount <= _maxSupply, "MultisendERC20Token: Cannot mint more than max supply");
        super._mint(account, amount);
    }
}