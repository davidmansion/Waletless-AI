/** 
 * SPDX-License-Identifier: MIT
 * WalletLess AI Token Contract
 * Website : https://walletless.ai                                                           
                                        
 █░█░█ ▄▀█ █░░ █░░ █▀▀ ▀█▀ █░░ █▀▀ █▀ █▀
 ▀▄▀▄▀ █▀█ █▄▄ █▄▄ ██▄ ░█░ █▄▄ ██▄ ▄█ ▄█

*/

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract  WalletlessAI is ERC20, Ownable, Pausable {
    event pausedStatus(bool status);
    event claimedSpendingReward(address user, uint256 amount);
    
    uint256 public spendingRewardTokens = 5_000_000 ether;
    uint256 public spendingRewardRate = 200;

    mapping(address => bool) public _isExcluded;
    mapping(address => uint256) public spenindRewards;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        _mint(address(this), 5_000_000 * 10 ** 18); // 5M tokens for Spending Reward
        _mint(owner(), 113_500_000 * 10 ** 18); // 113.5 M  tokens 
        _isExcluded[owner()] = true;
        _isExcluded[address(this)] = true;
        
        }

    /**
     * @dev pausing the contract, where transfers or minting will be retricted
     */

    function pause() public onlyOwner {
        _pause();
        emit pausedStatus(true);
    }

    /**
     * @dev unpausing the contract, where transfers or minting will be possible
     */

    function unpause() public onlyOwner {
        _unpause();
        emit pausedStatus(false);
    }

    /**
     * @dev overriding before token transfer from ERC20 contract, adding whenNotPaused modifier to restrict transfers while paused.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }
    
    
    /**
     * @dev exclude an address from spending reward 
     * @param account address of lp token or sale contract etc
     */
    function excludeFromSpendingReward(address account) public onlyOwner {
        require(
            !_isExcluded[account],
            "WalletLess:  Account is already excluded"
        );
        _isExcluded[account] = true;
    }

     /**
     * @dev set spending reward percentage
     * @param _spendingRewardRate reward percentage 200 means 2% 
     */
    function setSpendingReward(uint256 _spendingRewardRate) public onlyOwner {
        require(_spendingRewardRate <= 1000, "WalletLess: too high"); // <= 10%
        spendingRewardRate = _spendingRewardRate;
    }


    function claimSpendingReward() external  {
        require(spenindRewards[msg.sender] > 0 && spenindRewards[msg.sender] <= spendingRewardTokens,"WalletLess: Not have enough Reward");
        spendingRewardTokens = spendingRewardTokens - spenindRewards[msg.sender];
         _transfer(address(this), msg.sender, spenindRewards[msg.sender]);
         emit claimedSpendingReward(msg.sender, spenindRewards[msg.sender]);
        spenindRewards[msg.sender] = 0;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal override {
        if (_isExcluded[_from]) {
             super._transfer(_from, _to, _amount);
        } else {
            uint256 spendingReward = (_amount * spendingRewardRate) / 10_000;
            if (spendingReward > 0) spenindRewards[_from] = spenindRewards[_from] +  spendingReward;  
            super._transfer(_from, _to, _amount);
        }
    }
}