//SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "../Manager/Member.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
interface ITokenStake {
    function update(uint256 amount) external;
}

contract Token is ERC20, Ownable, Member {
    using SafeMath for uint256;

    string private _name = "MP TOKEN";
    string private _symbol = "MP";

    event SwapReward(address from, address to, address lpaddr, uint256 amount, uint256 reward);

    constructor (
        uint256 _totalSupply
    ) ERC20(_name, _symbol) {
        _mint(msg.sender, _totalSupply);
    }
  
    function issue(uint256 amount) public onlyOwner {
        _mint(msg.sender, amount);
    }
    
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        if (manager.members("LPAddress") != address(0)) {
            address lpaddr = manager.members("LPAddress");
            address PancakeSwapPair = manager.members("PancakeSwapPair");
            uint256 reward = amount.mul(2).div(100);
            if (PancakeSwapPair != address(0) && to == PancakeSwapPair) {
                require(balanceOf(from) >= (amount + reward), "Token PancakeSwap: token not enough");
                _transfer(from, lpaddr, reward);
                _approve(from, _msgSender(), allowance(from, _msgSender()).sub(reward, "ERC20: transfer amount exceeds allowance"));
                emit SwapReward(from, to, lpaddr, amount, reward);
                ITokenStake(manager.members("LPAddress")).update(reward);
            }
        }
        
        _transfer(from, to, amount);
        _approve(from, _msgSender(), allowance(from, _msgSender()).sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
}