pragma solidity ^0.4.18;

import "./OpenZeppelin/MintableToken.sol";
import "./OpenZeppelin/BurnableToken.sol";

contract PTRToken is MintableToken, BurnableToken {

    string public constant name = "PTR";
    string public constant symbol = "PTR";
    uint32 public constant decimals = 14;

    function PTRToken() public {
        totalSupply = 400000000E14;
        balances[owner] = totalSupply; // Add all tokens to issuer balance (crowdsale in this case)
    }

}
