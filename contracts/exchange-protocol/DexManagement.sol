// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IArborSwapRouter02.sol";
import "./interfaces/IArborSwapFactory.sol";

// found issue with transfer fee tokens
contract DEXManagement is Ownable, Pausable, ReentrancyGuard {
    
    //--------------------------------------
    // State variables
    //--------------------------------------

    address public TREASURY;                // Must be multi-sig wallet or Treasury contract
    uint256 public SWAP_FEE;                // Fee = SWAP_FEE / 10000
    uint256 public SWAP_FEE_EXTERNAL;             // Fee = SWAP_FEE_EXTERNAL / 10000

    IArborSwapRouter02 public defaultRouter;
    IArborSwapRouter02 public externalRouter;

    //-------------------------------------------------------------------------
    // EVENTS
    //-------------------------------------------------------------------------

    event LogReceived(address indexed, uint);
    event LogFallback(address indexed, uint);
    event LogSetTreasury(address indexed, address indexed);
    event LogSetSwapFee(address indexed, uint256);
    event LogSetSwapFeeExternal(address indexed, uint256);
    event LogSetDexRouter(address indexed, address indexed);
    event LogWithdraw(address indexed, uint256, uint256);
    event LogSwapExactTokensForTokens(address indexed, address indexed, uint256, uint256);
    event LogSwapExactETHForTokens(address indexed, uint256, uint256);
    event LogSwapExactTokenForETH(address indexed, uint256, uint256);
    event LogSwapExactTokensForTokensEx(address indexed, address indexed, uint256, uint256);
    event LogSwapExactETHForTokensEx(address indexed, uint256, uint256);
    event LogSwapExactTokenForETHEx(address indexed, uint256, uint256);

    //-------------------------------------------------------------------------
    // CONSTRUCTOR
    //-------------------------------------------------------------------------

    /**
     * @param   _defaultRouter: default Arbor router address
     * @param   _externalRouter: external router address, can be pcs or else
     * @param   _treasury: treasury address
     * @param   _swapFee: swap fee value
     * @param   _swapFeeExternal: swap fee for External value
     */
    constructor(address _defaultRouter,address _externalRouter, address _treasury, uint256 _swapFee, uint256 _swapFeeExternal ) 
    {
        require(_treasury != address(0), "Zero address");
        defaultRouter = IArborSwapRouter02(_defaultRouter);
        externalRouter = IArborSwapRouter02(_externalRouter);
        TREASURY = _treasury;
        SWAP_FEE = _swapFee;
        SWAP_FEE_EXTERNAL = _swapFeeExternal;
    }

    /**
     * @param   _tokenA: tokenA contract address
     * @param   _tokenB: tokenB contract address
     * @return  bool: if pair is in Arbor, return true, else, return false.
     */
    function isPairExists(address _tokenA, address _tokenB) public view returns(bool){        
        return IArborSwapFactory(defaultRouter.factory()).getPair(_tokenA, _tokenB) != address(0);
    }

    /**
     * @param   _tokenA: tokenA contract address
     * @param   _tokenB: tokenB contract address
     * @return  bool: if pair is in External, return true, else, return false.
     */
    function isPairExistsEx(address _tokenA, address _tokenB) public view returns(bool){        
        return IArborSwapFactory(externalRouter.factory()).getPair(_tokenA, _tokenB) != address(0);
    }

    /**
     * @param   _tokenA: tokenA contract address
     * @param   _tokenB: tokenB contract address
     * @return  bool: if path is in DEX, return true, else, return false.
     */
    function isPathExists(address _tokenA, address _tokenB) public view returns(bool){        
        return IArborSwapFactory(defaultRouter.factory()).getPair(_tokenA, _tokenB) != address(0) || 
            (IArborSwapFactory(defaultRouter.factory()).getPair(_tokenA, defaultRouter.WETH()) != address(0) && 
            IArborSwapFactory(defaultRouter.factory()).getPair(defaultRouter.WETH(), _tokenB) != address(0));
    }

    /**
     * @param   _tokenA: tokenA contract address
     * @param   _tokenB: tokenB contract address
     * @return  bool: if path is in External, return true, else, return false.
     */
    function isPathExistsEx(address _tokenA, address _tokenB) public view returns(bool){        
        return IArborSwapFactory(defaultRouter.factory()).getPair(_tokenA, _tokenB) != address(0) || 
            (IArborSwapFactory(defaultRouter.factory()).getPair(_tokenA, defaultRouter.WETH()) != address(0) && 
            IArborSwapFactory(defaultRouter.factory()).getPair(defaultRouter.WETH(), _tokenB) != address(0));
    }

    /**
     * @param   tokenIn: tokenIn contract address
     * @param   tokenOut: tokenOut contract address
     * @param   _amountIn: amount of input token
     * @return  uint256: Given an input asset amount, returns the maximum output amount of the other asset.
     */
    function getAmountOut(address tokenIn, address tokenOut, uint256 _amountIn) external view returns(uint256) { 
        require(_amountIn > 0 , "Invalid amount");
        require(isPathExists(tokenIn, tokenOut), "Invalid path");

        address[] memory path;
        if (isPairExists(tokenIn, tokenOut))
        {
            path = new address[](2);
            path[0] = tokenIn;
            path[1] = tokenOut;
        }
        else {
            path = new address[](3);
            path[0] = tokenIn;
            path[1] = defaultRouter.WETH();
            path[2] = tokenOut;
        }
        uint256[] memory amountOutMaxs = defaultRouter.getAmountsOut(_amountIn * (10000 - SWAP_FEE) / 10000, path);
        return amountOutMaxs[path.length - 1];  
    }

    /**
     * @param   tokenIn: tokenIn contract address
     * @param   tokenOut: tokenOut contract address
     * @param   _amountOut: amount of output token
     * @return  uint256: Returns the minimum input asset amount required to buy the given output asset amount.
     */
    function getAmountInEx(address tokenIn, address tokenOut, uint256 _amountOut) external view returns(uint256) { 
        require(_amountOut > 0 , "Invalid amount");
        require(isPathExistsEx(tokenIn, tokenOut), "Invalid path");

        address[] memory path;
        if (isPairExistsEx(tokenIn, tokenOut))
        {
            path = new address[](2);
            path[0] = tokenIn;
            path[1] = tokenOut;
        } 
        else {
            path = new address[](3);
            path[0] = tokenIn;
            path[1] = defaultRouter.WETH();
            path[2] = tokenOut;
        }
        uint256[] memory amountInMins = externalRouter.getAmountsIn(_amountOut, path);
        return amountInMins[0] * 10000 / (10000 - SWAP_FEE);
    }

    /**
     * @param   tokenIn: tokenIn contract address
     * @param   tokenOut: tokenOut contract address
     * @param   _amountIn: amount of input token
     * @return  uint256: Given an input asset amount, returns the maximum output amount of the other asset.
     */
    function getAmountOutEx(address tokenIn, address tokenOut, uint256 _amountIn) external view returns(uint256) { 
        require(_amountIn > 0 , "Invalid amount");
        require(isPathExistsEx(tokenIn, tokenOut), "Invalid path");

        address[] memory path;
        if (isPairExistsEx(tokenIn, tokenOut))
        {
            path = new address[](2);
            path[0] = tokenIn;
            path[1] = tokenOut;
        }
        else {
            path = new address[](3);
            path[0] = tokenIn;
            path[1] = defaultRouter.WETH();
            path[2] = tokenOut;
        }
        uint256[] memory amountOutMaxs = externalRouter.getAmountsOut(_amountIn * (10000 - SWAP_FEE) / 10000, path);
        return amountOutMaxs[path.length - 1];  
    }

    /**
     * @param   tokenIn: tokenIn contract address
     * @param   tokenOut: tokenOut contract address
     * @param   _amountOut: amount of output token
     * @return  uint256: Returns the minimum input asset amount required to buy the given output asset amount.
     */
    function getAmountIn(address tokenIn, address tokenOut, uint256 _amountOut) external view returns(uint256) { 
        require(_amountOut > 0 , "Invalid amount");
        require(isPathExists(tokenIn, tokenOut), "Invalid path");

        address[] memory path;
        if (isPairExists(tokenIn, tokenOut))
        {
            path = new address[](2);
            path[0] = tokenIn;
            path[1] = tokenOut;
        } 
        else {
            path = new address[](3);
            path[0] = tokenIn;
            path[1] = defaultRouter.WETH();
            path[2] = tokenOut;
        }
        uint256[] memory amountInMins = defaultRouter.getAmountsIn(_amountOut, path);
        return amountInMins[0] * 10000 / (10000 - SWAP_FEE);
    }

    /**
     * @param   tokenA: InputToken Address to swap on Arborswap
     * @param   tokenB: OutputToken Address to swap on Arborswap
     * @param   _amountIn: Amount of InputToken to swap on Arborswap
     * @param   _amountOutMin: The minimum amount of output tokens that must be received for the transaction not to revert.
     * @param   to: Recipient of the output tokens.
     * @param   deadline: Deadline, Timestamp after which the transaction will revert.
     * @notice  Swap ERC20 token to ERC20 token on Arborswap
     */
    function swapExactTokensForTokens(
        address tokenA, 
        address tokenB, 
        uint256 _amountIn, 
        uint256 _amountOutMin, 
        address to, 
        uint deadline
    ) external whenNotPaused nonReentrant {
        require(isPathExists(tokenA, tokenB), "Invalid path");
        require(_amountIn > 0 , "Invalid amount");

        require(IERC20(tokenA).transferFrom(_msgSender(), address(this), _amountIn), "Faild TransferFrom");

        uint256 _swapAmountIn = _amountIn * (10000 - SWAP_FEE) / 10000;
        
        require(IERC20(tokenA).approve(address(defaultRouter), _swapAmountIn));

        address[] memory path;
        if (isPairExists(tokenA, tokenB)) 
        {
            path = new address[](2);
            path[0] = tokenA;
            path[1] = tokenB;
        }         
        else {
            path = new address[](3);
            path[0] = tokenA;
            path[1] = defaultRouter.WETH();
            path[2] = tokenB;
        }
        
        uint256 boughtAmount = IERC20(tokenB).balanceOf(to);
        defaultRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _swapAmountIn,
            _amountOutMin,  
            path,
            to,
            deadline
        );
        boughtAmount = IERC20(tokenB).balanceOf(to) - boughtAmount;

        require(IERC20(tokenA).transfer(TREASURY, _amountIn - _swapAmountIn), "Faild Transfer");

        emit LogSwapExactTokensForTokens(tokenA, tokenB, _amountIn, boughtAmount);
    }

    /**
     * @param   token: OutputToken Address to swap on Arborswap
     * @param   _amountOutMin: The minimum amount of output tokens that must be received for the transaction not to revert.
     * @param   to: Recipient of the output tokens.
     * @param   deadline: Deadline, Timestamp after which the transaction will revert.
     * @notice  Swap ETH to ERC20 token on Arborswap
     */
    function swapExactETHForTokens(
        address token, 
        uint256 _amountOutMin, 
        address to, 
        uint deadline
    ) external payable whenNotPaused nonReentrant {
        require(isPathExists(token, defaultRouter.WETH()), "Invalid path");
        require(msg.value > 0 , "Invalid amount");

        address[] memory path = new address[](2);
        path[0] = defaultRouter.WETH();
        path[1] = token;

        uint256 _swapAmountIn = msg.value * (10000 - SWAP_FEE) / 10000;

        uint256 boughtAmount = IERC20(token).balanceOf(to);
        defaultRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: _swapAmountIn}(                
            _amountOutMin,
            path,
            to,
            deadline
        );
        boughtAmount = IERC20(token).balanceOf(to) - boughtAmount;

        payable(TREASURY).transfer(msg.value - _swapAmountIn);

        emit LogSwapExactETHForTokens(token, msg.value, boughtAmount);
    }

    /**
     * @param   token: InputToken Address to swap on Arborswap
     * @param   _amountIn: Amount of InputToken to swap on Arborswap
     * @param   _amountOutMin: The minimum amount of output tokens that must be received for the transaction not to revert.
     * @param   to: Recipient of the output tokens.
     * @param   deadline: Deadline, Timestamp after which the transaction will revert.
     * @notice  Swap ERC20 token to ETH on Arborswap
     */
    function swapExactTokenForETH(
        address token, 
        uint256 _amountIn, 
        uint256 _amountOutMin, 
        address to, 
        uint deadline
    ) external whenNotPaused nonReentrant {
        require(isPathExists(token, defaultRouter.WETH()), "Invalid path");
        require(_amountIn > 0 , "Invalid amount");

        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = defaultRouter.WETH();
        
        require(IERC20(token).transferFrom(_msgSender(), address(this), _amountIn), "Faild TransferFrom");
        uint256 _swapAmountIn = _amountIn * (10000 -  SWAP_FEE) / 10000;
        
        require(IERC20(token).approve(address(defaultRouter), _swapAmountIn));

        uint256 boughtAmount = address(to).balance;
        defaultRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(   
            _swapAmountIn,         
            _amountOutMin,         
            path,
            to,
            deadline
        );
        boughtAmount = address(to).balance - boughtAmount;

        require(IERC20(token).transfer(TREASURY, _amountIn - _swapAmountIn), "Faild Transfer");

        emit LogSwapExactTokenForETH(token, _amountIn, boughtAmount);
    }

    /**
     * @param   tokenA: InputToken Address to swap on External
     * @param   tokenB: OutputToken Address to swap on External
     * @param   _amountIn: Amount of InputToken to swap on External
     * @param   _amountOutMin: The minimum amount of output tokens that must be received for the transaction not to revert.
     * @param   to: Recipient of the output tokens.
     * @param   deadline: Deadline, Timestamp after which the transaction will revert.
     * @notice  Swap ERC20 token to ERC20 token on External
     */
    function swapExactTokensForTokensEx(
        address tokenA, 
        address tokenB, 
        uint256 _amountIn, 
        uint256 _amountOutMin, 
        address to, 
        uint deadline
    ) external whenNotPaused nonReentrant {
        require(isPathExistsEx(tokenA, tokenB), "Invalid path");
        require(_amountIn > 0 , "Invalid amount");

        require(IERC20(tokenA).transferFrom(_msgSender(), address(this), _amountIn), "Faild TransferFrom");

        uint256 _swapAmountIn = _amountIn * (10000 - SWAP_FEE) / 10000;
        
        require(IERC20(tokenA).approve(address(externalRouter), _swapAmountIn));

        address[] memory path;
        if (isPairExistsEx(tokenA, tokenB)) 
        {
            path = new address[](2);
            path[0] = tokenA;
            path[1] = tokenB;
        }         
        else {
            path = new address[](3);
            path[0] = tokenA;
            path[1] = externalRouter.WETH();
            path[2] = tokenB;
        }
        
        uint256 boughtAmount = IERC20(tokenB).balanceOf(to);
        externalRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _swapAmountIn,
            _amountOutMin,  
            path,
            to,
            deadline
        );
        boughtAmount = IERC20(tokenB).balanceOf(to) - boughtAmount;

        require(IERC20(tokenA).transfer(TREASURY, _amountIn - _swapAmountIn), "Faild Transfer");

        emit LogSwapExactTokensForTokensEx(tokenA, tokenB, _amountIn, boughtAmount);
    }

    /**
     * @param   token: OutputToken Address to swap on External
     * @param   _amountOutMin: The minimum amount of output tokens that must be received for the transaction not to revert.
     * @param   to: Recipient of the output tokens.
     * @param   deadline: Deadline, Timestamp after which the transaction will revert.
     * @notice  Swap ETH to ERC20 token on External
     */
    function swapExactETHForTokensEx(
        address token, 
        uint256 _amountOutMin, 
        address to, 
        uint deadline
    ) external payable whenNotPaused nonReentrant {
        require(isPathExistsEx(token, externalRouter.WETH()), "Invalid path");
        require(msg.value > 0 , "Invalid amount");

        address[] memory path = new address[](2);
        path[0] = externalRouter.WETH();
        path[1] = token;

        uint256 _swapAmountIn = msg.value * (10000 - SWAP_FEE) / 10000;

        uint256 boughtAmount = IERC20(token).balanceOf(to);
        externalRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: _swapAmountIn}(                
            _amountOutMin,
            path,
            to,
            deadline
        );
        boughtAmount = IERC20(token).balanceOf(to) - boughtAmount;

        payable(TREASURY).transfer(msg.value - _swapAmountIn);

        emit LogSwapExactETHForTokensEx(token, msg.value, boughtAmount);
    }

    /**
     * @param   token: InputToken Address to swap on Arborswap
     * @param   _amountIn: Amount of InputToken to swap on Arborswap
     * @param   _amountOutMin: The minimum amount of output tokens that must be received for the transaction not to revert.
     * @param   to: Recipient of the output tokens.
     * @param   deadline: Deadline, Timestamp after which the transaction will revert.
     * @notice  Swap ERC20 token to ETH on Arborswap
     */
    function swapExactTokenForETHEx(
        address token, 
        uint256 _amountIn, 
        uint256 _amountOutMin, 
        address to, 
        uint deadline
    ) external whenNotPaused nonReentrant {
        require(isPathExistsEx(token, externalRouter.WETH()), "Invalid path");
        require(_amountIn > 0 , "Invalid amount");

        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = externalRouter.WETH();
        
        require(IERC20(token).transferFrom(_msgSender(), address(this), _amountIn), "Faild TransferFrom");
        uint256 _swapAmountIn = _amountIn * (10000 -  SWAP_FEE) / 10000;
        
        require(IERC20(token).approve(address(externalRouter), _swapAmountIn));

        uint256 boughtAmount = address(to).balance;
        externalRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(   
            _swapAmountIn,         
            _amountOutMin,         
            path,
            to,
            deadline
        );
        boughtAmount = address(to).balance - boughtAmount;

        require(IERC20(token).transfer(TREASURY, _amountIn - _swapAmountIn), "Faild Transfer");

        emit LogSwapExactTokenForETHEx(token, _amountIn, boughtAmount);
    }
    
    function withdraw(address token) external onlyOwner nonReentrant {
        require(IERC20(token).balanceOf(address(this)) > 0 || address(this).balance > 0, "Zero Balance!");

        if(address(this).balance > 0) {
            payable(_msgSender()).transfer(address(this).balance);
        }
        
        uint256 balance = IERC20(token).balanceOf(address(this));
        if(balance > 0) {
            require(IERC20(token).transfer(_msgSender(), balance), "Faild Transfer");
        }
        
        emit LogWithdraw(_msgSender(), balance, address(this).balance);
    }

    receive() external payable {
        emit LogReceived(_msgSender(), msg.value);
    }

    fallback() external payable { 
        emit LogFallback(_msgSender(), msg.value);
    }

    //-------------------------------------------------------------------------
    // set functions
    //-------------------------------------------------------------------------

    function setPause() external onlyOwner {
        _pause();
    }

    function setUnpause() external onlyOwner {
        _unpause();
    }

    function setTreasury(address _newTreasury) external onlyOwner whenNotPaused {
        require(TREASURY != _newTreasury, "Same address! Notice: Must be Multi-sig Wallet!");
        TREASURY = _newTreasury;

        emit LogSetTreasury(_msgSender(), TREASURY);
    }

    function setSwapFee(uint256 _newSwapFee) external onlyOwner whenNotPaused {
        require(SWAP_FEE != _newSwapFee, "Same value!");
        SWAP_FEE = _newSwapFee;

        emit LogSetSwapFee(_msgSender(), SWAP_FEE);
    }

    function setSwapFeeExternal(uint256 _newSwapFeeExternal) external onlyOwner whenNotPaused {
        require(SWAP_FEE_EXTERNAL != _newSwapFeeExternal, "Same value!");
        SWAP_FEE_EXTERNAL = _newSwapFeeExternal;

        emit LogSetSwapFeeExternal(_msgSender(), SWAP_FEE_EXTERNAL);
    }

    function setDefaultRouter(address _newRouter) external onlyOwner whenNotPaused {
        require(address(defaultRouter) != _newRouter, "Same router!");
        defaultRouter = IArborSwapRouter02(_newRouter);
        
        emit LogSetDexRouter(_msgSender(), address(defaultRouter));
    }

    function setExternalRouter(address _newRouter) external onlyOwner whenNotPaused {
        require(address(externalRouter) != _newRouter, "Same router!");
        externalRouter = IArborSwapRouter02(_newRouter);
        
        emit LogSetDexRouter(_msgSender(), address(externalRouter));
    }
}
