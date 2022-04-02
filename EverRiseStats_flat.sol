// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

// File: EverRise-v3/Interfaces/IERC173-Ownable.sol

interface IOwnable {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
}
// File: EverRise-v3/Abstract/Context.sol

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}
// File: EverRise-v3/Abstract/ErrorNotZeroAddress.sol

error NotZeroAddress();    // 0x66385fa3
error CallerNotApproved(); // 0x4014f1a5
error InvalidAddress();    // 0xe6c4247b
// File: EverRise-v3/Abstract/ERC173-Ownable.sol

error CallerNotOwner();
error UseEverOwn();

contract Ownable is IOwnable, Context {
    address public owner;

    function _onlyOwner() private view {
        if (owner != _msgSender()) revert CallerNotOwner();
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    constructor() {
        address msgSender = _msgSender();
        owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    // Allow contract ownership and access to contract onlyOwner functions
    // to be locked using EverOwn with control gated by community vote.
    //
    // EverRise ($RISE) stakers become voting members of the
    // decentralized autonomous organization (DAO) that controls access
    // to the token contract via the EverRise Ecosystem dApp EverOwn
    function transferOwnership(address newOwner) external virtual onlyOwner {
        if (newOwner == address(0)) revert NotZeroAddress();

        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
// File: EverRise-v3/Interfaces/IERC721-Nft.sol

interface IERC721 /* is ERC165 */ {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

/// @dev Note: the ERC-165 identifier for this interface is 0x150b7a02.
interface IERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external view returns(bytes4);
}

interface IERC721Metadata /* is ERC721 */ {
    function name() external view returns (string memory _name);
    function symbol() external view returns (string memory _symbol);
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

interface IERC721Enumerable /* is ERC721 */ {
    function totalSupply() external view returns (uint256);
    function tokenByIndex(uint256 _index) external view returns (uint256);
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}

// File: EverRise-v3/Interfaces/InftEverRise.sol

struct StakingDetails {
    uint96 initialTokenAmount;    // Max 79 Bn tokens
    uint96 withdrawnAmount;       // Max 79 Bn tokens
    uint48 depositTime;           // 8 M years
    uint8 numOfMonths;            // Max 256 month period
    uint8 achievementClaimed;
    // 256 bits, 20000 gwei gas
    address stakerAddress;        // 160 bits (96 bits remaining)
    uint32 nftId;                 // Max 4 Bn nfts issued
    uint32 lookupIndex;           // Max 4 Bn active stakes
    uint24 stakerIndex;           // Max 16 M active stakes per wallet
    uint8 isActive;
    // 256 bits, 20000 gwei gas
} // Total 768 bits, 40000 gwei gas

interface InftEverRise is IERC721 {
    function voteEscrowedBalance(address account) external view returns (uint256);
    function unclaimedRewardsBalance(address account) external view returns (uint256);
    function totalAmountEscrowed() external view returns (uint256);
    function totalAmountVoteEscrowed() external view returns (uint256);
    function totalRewardsDistributed() external view returns (uint256);
    function totalRewardsUnclaimed() external view returns (uint256);

    function createRewards(uint256 tAmount) external;

    function getNftData(uint256 id) external view returns (StakingDetails memory);
    function enterStaking(address fromAddress, uint96 amount, uint8 numOfMonths) external returns (uint32 nftId);
    function leaveStaking(address fromAddress, uint256 id, bool overrideNotClaimed) external returns (uint96 amount);
    function earlyWithdraw(address fromAddress, uint256 id, uint96 amount) external returns (uint32 newNftId, uint96 penaltyAmount);
    function withdraw(address fromAddress, uint256 id, uint96 amount, bool overrideNotClaimed) external returns (uint32 newNftId);
    function bridgeStakeNftOut(address fromAddress, uint256 id) external returns (uint96 amount);
    function bridgeOrAirdropStakeNftIn(address toAddress, uint96 depositAmount, uint8 numOfMonths, uint48 depositTime, uint96 withdrawnAmount, uint96 rewards, bool achievementClaimed) external returns (uint32 nftId);
    function addStaker(address staker, uint256 nftId) external;
    function removeStaker(address staker, uint256 nftId) external;
    function reissueStakeNft(address staker, uint256 oldNftId, uint256 newNftId) external;
    function increaseStake(address staker, uint256 nftId, uint96 amount) external returns (uint32 newNftId, uint96 original, uint8 numOfMonths);
    function splitStake(uint256 id, uint96 amount) external payable returns (uint32 newNftId0, uint32 newNftId1);
    function claimAchievement(address staker, uint256 nftId) external returns (uint32 newNftId);
    function stakeCreateCost() external view returns (uint256);
    function approve(address owner, address _operator, uint256 nftId) external;
}
// File: EverRise-v3/Interfaces/IEverRiseWallet.sol

struct ApprovalChecks {
    // Prevent permits being reused (IERC2612)
    uint64 nonce;
    // Allow revoke all spenders/operators approvals in single txn
    uint32 nftCheck;
    uint32 tokenCheck;
    // Allow auto timeout on approvals
    uint16 autoRevokeNftHours;
    uint16 autoRevokeTokenHours;
    // Allow full wallet locking of all transfers
    uint48 unlockTimestamp;
}

struct Allowance {
    uint128 tokenAmount;
    uint32 nftCheck;
    uint32 tokenCheck;
    uint48 timestamp;
    uint8 nftApproval;
    uint8 tokenApproval;
}

interface IEverRiseWallet {
    event RevokeAllApprovals(address indexed account, bool tokens, bool nfts);
    event SetApprovalAutoTimeout(address indexed account, uint16 tokensHrs, uint16 nftsHrs);
    event LockWallet(address indexed account, address altAccount, uint256 length);
    event LockWalletExtend(address indexed account, uint256 length);
}
// File: EverRise-v3/Interfaces/IUniswap.sol

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r,bytes32 s) external;
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function nonces(address owner) external view returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function MINIMUM_LIQUIDITY() external pure returns (uint256);
}

interface IUniswapV2Router01 {
    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);
    function addLiquidity(address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
    function removeLiquidity(address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETH(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external returns (uint256 amountToken, uint256 amountETH);
    function removeLiquidityWithPermit(address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETHWithPermit(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountToken, uint256 amountETH);
    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
    function swapTokensForExactTokens(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
    function swapTokensForExactETH(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
    function swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountOut);
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountIn);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external returns (uint256 amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline ) external;
}
// File: EverRise-v3/Interfaces/IERC20-Token.sol

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transferFromWithPermit(address sender, address recipient, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
// File: EverRise-v3/Interfaces/IEverRise.sol

interface IEverRise is IERC20Metadata {
    function totalBuyVolume() external view returns (uint256);
    function totalSellVolume() external view returns (uint256);
    function holders() external view returns (uint256);
    function uniswapV2Pair() external view returns (address);
    function transferStake(address fromAddress, address toAddress, uint96 amountToTransfer) external;
    function isWalletLocked(address fromAddress) external view returns (bool);
    function setApprovalForAll(address fromAddress, address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function isExcludedFromFee(address account) external view returns (bool);

    function approvals(address operator) external view returns (ApprovalChecks memory);
}
// File: EverRise-v3/EverRiseStats.sol

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function latestRoundData() external view 
    returns (
        uint80 roundId, 
        int256 answer, 
        uint256 startedAt, 
        uint256 updatedAt, 
        uint80 answeredInRound
    );
}

contract EverRiseStats is Ownable {
    event UsdOracleAddressUpdated(address prevValue, address newValue);
    event EverRiseAddressUpdated(address prevValue, address newValue);
    event EverBridgeVaultAddressUpdated(address prevValue, address newValue);
    event CoinStablePairAddressUpdated(address prevValue, address newValue);
    event EverStakeAddressUpdated(address prevValue, address newValue);

    uint256 public tokenDivisor;
    uint256 public coinDivisor;

    address public everRiseAddress;
    IEverRise private everRise = IEverRise(everRiseAddress);

    address public everStakeAddress;
    InftEverRise private everStake = InftEverRise(everStakeAddress);

    address public everBridgeVaultAddress = 0x7D92730C33032e2770966C4912b3c9917995dC4E;

    address public pairAddress;
    IUniswapV2Pair private pair;
    address public usdOracleAddress;
    AggregatorV3Interface private usdOracle;

    address public coinStablePairAddress;
    IUniswapV2Pair private coinStablePair;
    address public wrappedCoinAddress;
    IERC20Metadata private wrappedCoin;
    address public stableAddress;
    IERC20Metadata private stableToken;
    uint8 private tokenDecimals;
    uint8 private coinDecimals;

    // BSC
    //     usdOracleAddress = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE; Chainlink: BNB/USD Price Feed
    //     coinStablePairAddress = 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16;  WBNB/BUSD
    // Eth
    //     usdOracleAddress = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419; Chainlink: ETH/USD Price Feed
    //     coinStablePairAddress = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc;  WETH/USDC
    // Poly
    //     usdOracleAddress = 0xAB594600376Ec9fD91F8e885dADF0CE036862dE0; Chainlink: MATIC/USD Price Feed
    //     coinStablePairAddress = 0x6e7a5FAFcec6BB1e78bAE2A1F0B612012BF14827;  WMATIC/USDC
    // AVAX
    //     usdOracleAddress = 0x0A77230d17318075983913bC2145DB16C7366156; Chainlink: AVAX/USD Price Feed
    //     coinStablePairAddress = 0xA389f9430876455C36478DeEa9769B7Ca4E3DDB1;  AVAX/USDC
    // FTM
    //     usdOracleAddress = 0xf4766552D15AE4d256Ad41B6cf2933482B0680dc; Chainlink: FTM/USD Price Feed
    //     coinStablePairAddress = 0x2b4C76d0dc16BE1C31D4C1DC53bF9B45987Fc75c;  FTM/USDC

    constructor(address _everRiseAddress, address _everStakeAddress, address _usdOracleAddress, address _coinStablePairAddress) {
        require(
            _coinStablePairAddress != address(0),
            "_coinStablePairAddress should not be the zero address"
        );
        require(
            _usdOracleAddress != address(0),
            "_usdOracleAddress should not be the zero address"
        );
        everRiseAddress = _everRiseAddress;
        everStakeAddress = _everStakeAddress;

        usdOracleAddress = _usdOracleAddress;
        usdOracle = AggregatorV3Interface(_usdOracleAddress);

        coinStablePairAddress = _coinStablePairAddress;
        coinStablePair = IUniswapV2Pair(_coinStablePairAddress);

        init();
    }

    function init() private {
        pairAddress = everRise.uniswapV2Pair();
        pair = IUniswapV2Pair(pairAddress);
        wrappedCoinAddress = pair.token0();
        if (wrappedCoinAddress == everRiseAddress){
            wrappedCoinAddress = pair.token1();
        }

        wrappedCoin = IERC20Metadata(wrappedCoinAddress);

        stableAddress = coinStablePair.token0();
        if (stableAddress == wrappedCoinAddress){
            stableAddress = coinStablePair.token1();
        }
        
        stableToken = IERC20Metadata(stableAddress);

        tokenDecimals = everRise.decimals();
        tokenDivisor = 10 ** uint256(tokenDecimals);
        coinDecimals = wrappedCoin.decimals();
        coinDivisor = 10 ** uint256(coinDecimals);
    }

    function name() external pure returns (string memory) {
        return "EverRise Stats";
    }

    struct Stats {
        uint256 reservesBalance;
        uint256 liquidityToken;
        uint256 liquidityCoin;
        uint256 staked;
        uint256 aveMultiplier;
        uint256 rewards;
        uint256 volumeBuy;
        uint256 volumeSell;
        uint256 volumeTrade;
        uint256 bridgeVault;
        uint256 tokenPriceCoin;
        uint256 coinPriceStable;
        uint256 tokenPriceStable;
        uint256 marketCap;
        uint128 blockNumber;
        uint64 timestamp;
        uint32 holders;
        uint8 tokenDecimals;
        uint8 coinDecimals;
        uint8 stableDecimals;
        uint8 multiplierDecimals;
    }

    function getStats() external view returns (Stats memory stats) {
        (uint256 liquidityToken,
        uint256 liquidityCoin,
        uint256 coinPriceStable,
        uint8 stableDecimals,
        uint256 tokenPriceCoin,
        uint256 tokenPriceStable) = getTokenPrices();

        uint256 buyVolume = everRise.totalBuyVolume();
        uint256 sellVolume = everRise.totalSellVolume();
        uint256 tradeVolume = buyVolume + sellVolume;

        uint256 totalAmountStaked = everStake.totalAmountEscrowed();
        uint256 aveMultiplier = totalAmountStaked == 0 ? 
            0 : 
            (everStake.totalAmountVoteEscrowed() * (10 ** 8)) / totalAmountStaked;

        uint256 marketCap = (tokenPriceStable * everRise.totalSupply()) / tokenDivisor;

        stats = Stats(
            everRiseAddress.balance,
            liquidityToken,
            liquidityCoin,
            totalAmountStaked,
            aveMultiplier,
            everStake.totalRewardsDistributed(),
            buyVolume,
            sellVolume,
            tradeVolume,
            everRise.balanceOf(everBridgeVaultAddress),
            tokenPriceCoin,
            coinPriceStable,
            tokenPriceStable,
            marketCap,
            uint128(block.number),
            uint64(block.timestamp),
            uint32(everRise.holders()),
            tokenDecimals,
            coinDecimals,
            stableDecimals,
            8
        );

        return stats;
    }

    function getTokenPrices() public view returns (
        uint256 liquidityToken,
        uint256 liquidityCoin,
        uint256 coinPriceStable,
        uint8 stableDecimals,
        uint256 tokenPriceCoin,
        uint256 tokenPriceStable) {
        liquidityToken = everRise.balanceOf(pairAddress);
        liquidityCoin = wrappedCoin.balanceOf(pairAddress);

        (coinPriceStable, stableDecimals) = getCoinPrice();
        if (liquidityToken > 0) {
            tokenPriceCoin = (liquidityCoin * tokenDivisor) / liquidityToken;
        } else {
            tokenPriceCoin = 0;
        }

        tokenPriceStable = (tokenPriceCoin * coinPriceStable) / coinDivisor;
    }

    function setEverBridgeVaultAddress(address _everBridgeVaultAddress)
        external
        onlyOwner
    {
        require(
            _everBridgeVaultAddress != address(0),
            "_everBridgeVaultAddress should not be the zero address"
        );
        
        emit EverBridgeVaultAddressUpdated(everBridgeVaultAddress, _everBridgeVaultAddress);

        everBridgeVaultAddress = _everBridgeVaultAddress;
    }

    function setEverRiseAddress(address _everRiseAddress)
        external
        onlyOwner
    {
        require(
            _everRiseAddress != address(0),
            "_everRiseAddress should not be the zero address"
        );

        emit EverRiseAddressUpdated(everRiseAddress, _everRiseAddress);

        everRiseAddress = _everRiseAddress;
        everRise = IEverRise(_everRiseAddress);
        
        init();
    }

    function setUsdOracleAddress(address _usdOracleAddress)
        external
        onlyOwner
    {
        require(
            _usdOracleAddress != address(0),
            "_usdOracleAddress should not be the zero address"
        );

        emit UsdOracleAddressUpdated(usdOracleAddress, _usdOracleAddress);

        usdOracleAddress = _usdOracleAddress;
        usdOracle = AggregatorV3Interface(_usdOracleAddress);
    }

    function setCoinStablePairAddress(address _coinStablePairAddress)
        external
        onlyOwner
    {
        require(
            _coinStablePairAddress != address(0),
            "_coinStablePairAddress should not be the zero address"
        );

        emit CoinStablePairAddressUpdated(coinStablePairAddress, _coinStablePairAddress);

        coinStablePairAddress = _coinStablePairAddress;
        coinStablePair = IUniswapV2Pair(_coinStablePairAddress);
        
        init();
    }

    function setEverStakeAddress(address _everStakeAddress)
        external
        onlyOwner
    {
        require(
            _everStakeAddress != address(0),
            "_everStakeAddress should not be the zero address"
        );

        emit EverStakeAddressUpdated(everStakeAddress, _everStakeAddress);

        everStakeAddress = _everStakeAddress;
        everStake = InftEverRise(_everStakeAddress);
    }

    function getCoinPrice() public view returns (uint256 coinPrice, uint8 usdDecimals) {
        try usdOracle.latestRoundData() returns (
            uint80,         // roundID
            int256 price,   // price
            uint256,        // startedAt
            uint256,        // timestamp
            uint80          // answeredInRound
        ) {
            coinPrice = uint256(price);
            usdDecimals = usdOracle.decimals();
        } catch Error(string memory) {
            (coinPrice, usdDecimals) = getCoinPriceFallback();
        }
    }

    function getCoinPriceFallback() public view returns (uint256 coinPrice, uint8 usdDecimals) {
        coinPrice = (stableToken.balanceOf(coinStablePairAddress) * coinDivisor)
            / wrappedCoin.balanceOf(coinStablePairAddress);
        usdDecimals = stableToken.decimals();
    }

    // Function to receive ETH when msg.data is be empty
    // Receives ETH from uniswapV2Router when swapping
    receive() external payable {}
 
    function transferExternalTokens(address tokenAddress, address toAddress) external onlyOwner {
        require(tokenAddress != address(0), "Token Address can not be a zero address");
        require(toAddress != address(0), "To Address can not be a zero address");
        require(IERC20(tokenAddress).balanceOf(address(this)) > 0, "Balance is zero");
        IERC20(tokenAddress).transfer(toAddress, IERC20(tokenAddress).balanceOf(address(this)));
    }

    function transferToAddressETH(address payable recipient) external onlyOwner {
        recipient.transfer(address(this).balance);
    }
}