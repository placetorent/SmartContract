pragma solidity ^0.4.23;


/*
 * Place to Rent Pre ICO and ICO Contract for Crowdsale
 *
*/


contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

}

contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value > 0);
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(burner, _value);
    }
}
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}
contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;


    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }
}

contract PTRTToken is MintableToken, BurnableToken {

    string public constant name = "Place To Rent";
    string public constant symbol = "PTRT";
    uint32 public constant decimals = 14;

    constructor() public {
        totalSupply = 100000000E14;
        balances[owner] = totalSupply; // Add all tokens to issuer balance (crowdsale in this case)
    }

}

contract TokenVesting is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20Basic;

  event Released(uint256 amount);
  event Revoked();

  // beneficiary of tokens after they are released
  address public beneficiary;

  uint256 public cliff;
  uint256 public start;
  uint256 public duration;

  bool public revocable;

  mapping (address => uint256) public released;
  mapping (address => bool) public revoked;

  /**
   * @dev Creates a vesting contract that vests its balance of any ERC20 token
   * of the balance will hav to the
   * _beneficiary, gradually in a linear fashion until _start + _duration. By then alle vested.
   * @param _beneficiary address of the beneficiary to whom vested tokens are transferred
   * @param _cliff duration in seconds of the cliff in which tokens will begin to vest
   * @param _duration duration in seconds of the period in which the tokens will vest
   * @param _revocable whether the vesting is revocable or not
   */
  constructor(
    address _beneficiary,
    uint256 _start,
    uint256 _cliff,
    uint256 _duration,
    bool _revocable
  )
    public
  {
    require(_beneficiary != address(0));
    require(_cliff <= _duration);

    beneficiary = _beneficiary;
    revocable = _revocable;
    duration = _duration;
    cliff = _start.add(_cliff);
    start = _start;
  }

  /**
   * @notice Transfers vested tokens to beneficiary.
   * @param token ERC20 token which is being vested
   */
  function release(ERC20Basic token) public {
    uint256 unreleased = releasableAmount(token);

    require(unreleased > 0);

    released[token] = released[token].add(unreleased);

    token.safeTransfer(beneficiary, unreleased);

    emit Released(unreleased);
  }

  /**
   * @notice Allows the owner to revoke the vesting. Tokens already vested
   * remain in the contract, the rest are returned to the owner.
   * @param token ERC20 token which is being vested
   */
  function revoke(ERC20Basic token) public onlyOwner {
    require(revocable);
    require(!revoked[token]);

    uint256 balance = token.balanceOf(this);

    uint256 unreleased = releasableAmount(token);
    uint256 refund = balance.sub(unreleased);

    revoked[token] = true;

    token.safeTransfer(owner, refund);

    emit Revoked();
  }

  /**
   * @dev Calculates the amount that has already vested but hasn't been released yet.
   * @param token ERC20 token which is being vested
   */
  function releasableAmount(ERC20Basic token) public view returns (uint256) {
    return vestedAmount(token).sub(released[token]);
  }

  /**
   * @dev Calculates the amount that has already vested.
   * @param token ERC20 token which is being vested
   */
  function vestedAmount(ERC20Basic token) public view returns (uint256) {
    uint256 currentBalance = token.balanceOf(this);
    uint256 totalBalance = currentBalance.add(released[token]);

    if (block.timestamp < cliff) {
      return 0;
    } else if (block.timestamp >= start.add(duration) || revoked[token]) {
      return totalBalance;
    } else {
      return totalBalance.mul(block.timestamp.sub(start)).div(duration);
    }
  }
}



library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}



contract PTRTCrowdSale is Ownable {

    using SafeMath for uint;

    PTRTToken public token = new PTRTToken();
    uint totalSupply = token.totalSupply();

    bool public isRefundAllowed;
    bool public newBonus_and_newPeriod;
    bool public new_bonus_for_next_period;

    uint public icoStartTime;
    uint public icoEndTime;
    uint public weiRaised;
    uint public hardCap; // amount of ETH collected, which marks end of crowd sale
     uint public softCap; 
    uint public tokensDistributed; // amount of bought tokens
    uint public bonus_for_add_stage;

    /*         Bonus variables          */
    uint internal baseBonus1 = 140;
    uint internal baseBonus2 = 135;
    uint internal baseBonus3 = 125;
    uint internal baseBonus4 = 115;
    uint internal baseBonus5 = 100;
    uint public manualBonus;
    /* * * * * * * * * * * * * * * * * * */

    uint public rate; // how many token units a buyer gets per wei
    uint private icoMinPurchase; // In ETH
    uint private icoEndDateIncCount;

    address[] public investors_number;
    address private wallet; // address where funds are collected

    mapping (address => uint) public orderedTokens;
    mapping (address => uint) contributors;

    event FundsWithdrawn(address _who, uint256 _amount);

    modifier hardCapNotReached() {
        require(weiRaised < hardCap);
        _;
    }

    modifier crowdsaleEnded() {
        require(now > icoEndTime);
        _;
    }

    modifier crowdsaleInProgress() {
        bool withinPeriod = (now >= icoStartTime && now <= icoEndTime);
        require(withinPeriod);
        _;
    }

     constructor() public {
       

        icoStartTime = 1528113840;
        icoEndTime = 1537922340;
        wallet = 0x241E97E0b8c62901a140b0FC882944EFBDA24Eba;  //    0xE321B36dE856591f14C0291C82Fb8698dF73753e;  //owner wallet this is done so that no one can hacked it

        rate = 20E14; // wei per 1 token

        hardCap = 100000 ether;
        softCap = 1500 ether;
        icoEndDateIncCount = 114; // june 4th till sept 2018
        icoMinPurchase = 200 finney; // 0.2 ETH
        isRefundAllowed = false;
    }

    // fallback function can be used to buy tokens
    function() public payable {
        buyTokens();
    }

    // low level token purchase function
    function buyTokens() public payable crowdsaleInProgress hardCapNotReached {
        require(msg.value > 0);

        // check if the buyer exceeded the funding goal
        calculatePurchaseAndBonuses(msg.sender, msg.value);
    }

    // Returns number of investors
    function getInvestorCount() public view returns (uint) {
        return investors_number.length;
    }

    // Owner can allow or disallow refunds even if soft cap is reached. Should be used in case KYC is not passed.
    // WARNING: owner should transfer collected ETH back to contract before allowing to refund, if he already withdrawn ETH.
    function toggleRefunds() public onlyOwner {
        isRefundAllowed = true;
    }

    // Sends ordered tokens to investors after ICO end if soft cap is reached
    // tokens can be send only if ico has ended
    function sendOrderedTokens() public onlyOwner crowdsaleEnded {
        address investor;
        uint tokensCount;
        for(uint i = 0; i < investors_number.length; i++) {
            investor = investors_number[i];
            tokensCount = orderedTokens[investor];
            assert(tokensCount > 0);
            orderedTokens[investor] = 0;
            token.transfer(investor, tokensCount);
        }
    }

    // Moves ICO ending date by one month. End date can be moved only 3 times.
    // Returns true if ICO end date was successfully shifted
    function moveIcoEndDateByOneMonth(uint bonus_percentage) public onlyOwner crowdsaleInProgress returns (bool) {
        if (icoEndDateIncCount < 3) {
            icoEndTime = icoEndTime.add(30 days);
            icoEndDateIncCount++;
            newBonus_and_newPeriod = true;
            bonus_for_add_stage = bonus_percentage;
            return true;
        }
        else {
            return false;
        }
    }

    // Owner can send back collected ETH if soft cap is not reached or KYC is not passed
    // WARNING: crowdsale contract should have all received funds to return them.
    // If you have already withdrawn them, send them back to crowdsale contract
    function refundInvestors() public onlyOwner {
        require(now >= icoEndTime);
        require(isRefundAllowed);
        require(msg.sender.balance > 0);

        address investor;
        uint contributedWei;
        uint tokens;
        for(uint i = 0; i < investors_number.length; i++) {
            investor = investors_number[i];
            contributedWei = contributors[investor];
            tokens = orderedTokens[investor];
            if(contributedWei > 0) {
                weiRaised = weiRaised.sub(contributedWei);
                contributors[investor] = 0;
                orderedTokens[investor] = 0;
                tokensDistributed = tokensDistributed.sub(tokens);
                investor.transfer(contributedWei); // return funds back to contributor
            }
        }
    }

    // Owner of contract can withdraw collected ETH, if soft cap is reached, by calling this function
    function withdraw() public onlyOwner {
        uint to_send = weiRaised;
        weiRaised = 0;
        emit FundsWithdrawn(msg.sender, to_send);
        wallet.transfer(to_send);
    }

    // This function should be used to manually reserve some tokens for "big sharks" or bug-bounty program participants
    function manualReserve(address _beneficiary, uint _amount) public onlyOwner crowdsaleInProgress {
        require(_beneficiary != address(0));
        require(_amount > 0);
        checkAndMint(_amount);
        tokensDistributed = tokensDistributed.add(_amount);
        token.transfer(_beneficiary, _amount);
    }

    function burnUnsold() public onlyOwner crowdsaleEnded {
        uint tokensLeft = totalSupply.sub(tokensDistributed);
        token.burn(tokensLeft);
    }

    function finishIco() public onlyOwner {
        icoEndTime = now;
    }

    function distribute_for_founders() public crowdsaleEnded onlyOwner {
        uint to_send = totalSupply.mul(30).div(70);
        checkAndMint(to_send);
        token.transfer(wallet, to_send);
    }

    function transferOwnershipToken(address _to) public onlyOwner {
        token.transferOwnership(_to);
    }

    /***************************
    **  Internal functions    **
    ***************************/

    // Calculates purchase conditions and token bonuses
    function calculatePurchaseAndBonuses(address _beneficiary, uint _weiAmount) internal {
        if (now >= icoStartTime && now < icoEndTime) require(_weiAmount >= icoMinPurchase);

        uint cleanWei; // amount of wei to use for purchase excluding change and hardcap overflows
        uint change;
        uint _tokens;

        //check for hardcap overflow
        if (_weiAmount.add(weiRaised) > hardCap) {
            cleanWei = hardCap.sub(weiRaised);
            change = _weiAmount.sub(cleanWei);
        }
        else cleanWei = _weiAmount;

        assert(cleanWei > 4); // 4 wei is a price of minimal fracture of token
        _tokens = cleanWei.mul(rate).mul(2500).div(1 ether);

        if (contributors[_beneficiary] == 0) investors_number.push(_beneficiary);

       // _tokens = calculateBonus(_tokens, cleanWei);
        checkAndMint(_tokens);

        contributors[_beneficiary] = contributors[_beneficiary].add(cleanWei);
        weiRaised = weiRaised.add(cleanWei);
        tokensDistributed = tokensDistributed.add(_tokens);
        orderedTokens[_beneficiary] = orderedTokens[_beneficiary].add(_tokens);

        if (change > 0) _beneficiary.transfer(change);
    }

    // Calculates bonuses based on current stage
    /*
    function calculateBonus(uint _baseAmount, uint _wei) internal returns (uint) {
        require(_baseAmount > 0 && _wei > 0);

        if (now >= icoStartTime && now < icoEndTime) {
            return   _baseAmount;//calculateBonusIco(_baseAmount, _wei);
        }
        else   
        return _baseAmount;
    }
*/
    function setBonusForNextStage (uint newBonusPercentage) public onlyOwner {
        manualBonus = newBonusPercentage.add(100);
        new_bonus_for_next_period = true;
    }

    function check_for_manual_bonus (uint _baseBonus) internal returns (uint) {
        if (new_bonus_for_next_period) {
            new_bonus_for_next_period = false;
            return manualBonus;
        } else
            return _baseBonus;
    }

    // Calculates bonuses, specific for the ICO
    // Contains date and volume based bonuses
    /* 
    function calculateBonusIco(uint _baseAmount, uint _wei) internal returns(uint) {
        if(now >= icoStartTime && now < 1530705900) {
            // 4 jun - 3 july - 40% bonus
            return _baseAmount.mul(baseBonus1).div(100);
        }
        else if(now >= 1530705901 && now < 1530965100) {
            // 4-17 jul - 35% bonus
          //  baseBonus1 = check_for_manual_bonus(baseBonus1);    // returns 127 if no changes detected
            return _baseAmount.mul(baseBonus2).div(100);
        }
        else if(now >= 1530965101 && now < 1534248300) {
            // 18 Jul - 14 Aug - 25% bonus
          //  baseBonus2 = check_for_manual_bonus(baseBonus2);
            return _baseAmount.mul(baseBonus3).div(100);
        }
        else if(now >= 1534248301 && now < icoEndTime) {
            // 15 Aug - 25 sep - 15%
         //   baseBonus3 = check_for_manual_bonus(baseBonus3);
            return _baseAmount.mul(baseBonus4).div(100);
        }
        
        else {
                return _baseAmount;
            }
       
    }
    */

    // Checks if more tokens should be minted based on amount of sold tokens, required additional tokens and total supply.
    // If there are not enough tokens, mint missing tokens
    function checkAndMint(uint _amount) internal {
        uint required = tokensDistributed.add(_amount);
        if(required > totalSupply) token.mint(this, required.sub(totalSupply));
    }
}

