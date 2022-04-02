// Copyright (c) 2022 EverRise Pte Ltd. All rights reserved.
// EverRise licenses this file to you under the MIT license.

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

error NotZeroAddress();    // 0x66385fa3
error CallerNotApproved(); // 0x4014f1a5
error InvalidAddress();    // 0xe6c4247b
error NotSetup();                    // 0xb09c99c0
error CallerNotOwner();
error UseEverOwn();
// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.01
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018-2019. The MIT Licence.
// ----------------------------------------------------------------------------

library BokkyPooBahsDateTimeLibrary {

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    uint constant DOW_MON = 1;
    uint constant DOW_TUE = 2;
    uint constant DOW_WED = 3;
    uint constant DOW_THU = 4;
    uint constant DOW_FRI = 5;
    uint constant DOW_SAT = 6;
    uint constant DOW_SUN = 7;

    // ------------------------------------------------------------------------
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    //
    // int L = days + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function _daysToDate(uint _days) private pure returns (uint year, uint month, uint day) {
        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampToDateTime(uint timestamp) internal pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }
}
// File: EverRise-v3/Abstract/base64.sol

/// @title Base64
/// @author Brecht Devos - <brecht@loopring.org>
/// @notice Provides functions for encoding/decoding base64
library Base64 {
    string private constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return '';

        // load the table into memory
        string memory table = TABLE_ENCODE;

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 3 bytes at a time
            for {} lt(dataPtr, endPtr) {}
            {
                // read 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // write 4 characters
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
    }
}
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

// File: EverRise-v3/Abstract/ERC173-Ownable.sol

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
// File: EverRise-v3/Interfaces/IEverRiseRendererGlyph.sol

// Copyright (c) 2022 EverRise Pte Ltd. All rights reserved.
// EverRise licenses this file to you under the MIT license.

interface IEverRiseRendererGlyph {
    function glyph(uint256 threshold) external pure returns (bytes memory);
}
// File: EverRise-v3/Interfaces/IERC721-Nft.sol

/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
interface IERC721 /* is ERC165 */ {

    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns (uint256);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns (address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

/// @dev Note: the ERC-165 identifier for this interface is 0x150b7a02.
interface IERC721TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external view returns(bytes4);
}

/// @title ERC-721 Non-Fungible Token Standard, optional metadata extension
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x5b5e139f.
interface IERC721Metadata /* is ERC721 */ {
    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string memory _name);

    /// @notice An abbreviated name for NFTs in this contract
    function symbol() external view returns (string memory _symbol);

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

/// @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x780e9d63.
interface IERC721Enumerable /* is ERC721 */ {
    /// @notice Count NFTs tracked by this contract
    /// @return A count of valid NFTs tracked by this contract, where each one of
    ///  them has an assigned and queryable owner not equal to the zero address
    function totalSupply() external view returns (uint256);

    /// @notice Enumerate valid NFTs
    /// @dev Throws if `_index` >= `totalSupply()`.
    /// @param _index A counter less than `totalSupply()`
    /// @return The token identifier for the `_index`th NFT,
    ///  (sort order not specified)
    function tokenByIndex(uint256 _index) external view returns (uint256);

    /// @notice Enumerate NFTs assigned to an owner
    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid NFTs.
    /// @param _owner An address where we are interested in NFTs owned by them
    /// @param _index A counter less than `balanceOf(_owner)`
    /// @return The token identifier for the `_index`th NFT assigned to `_owner`,
    ///   (sort order not specified)
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}

// File: EverRise-v3/Interfaces/InftEverRise.sol

// Copyright (c) 2022 EverRise Pte Ltd. All rights reserved.
// EverRise licenses this file to you under the MIT license.

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

interface InftEverRise {
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
}
// File: EverRise-v3/Interfaces/IEverRiseRenderer.sol

// Copyright (c) 2022 EverRise Pte Ltd. All rights reserved.
// EverRise licenses this file to you under the MIT license.

interface IOpenSeaCollectible {
    function contractURI() external view returns (string memory);
}

interface IEverRiseRenderer is IOpenSeaCollectible {
    event SetEverRiseNftStakes(address indexed addressStakes);
    event SetEverRiseRendererGlyph(address indexed addressGlyphs);
    
    function tokenURI(uint256 _tokenId) external view returns (string memory);

    function everRiseNftStakes() external view returns (InftEverRise);
    function setEverRiseNftStakes(address contractAddress) external;
}
// File: EverRise-v3/EverRiseRenderer.sol

// Copyright (c) 2022 EverRise Pte Ltd. All rights reserved.
// EverRise licenses this file to you under the MIT license.

contract EverRiseRenderer is Ownable, IEverRiseRenderer {
    InftEverRise public everRiseNftStakes;
    IEverRiseRendererGlyph public everRiseRendererGlyph;
    
    uint8 constant private _TRUE8 = 2;
    GradientColors[] private _gradients;

    constructor(){
        // Iron
        _gradients.push(GradientColors({
            color1: 0x303334,
            color2: 0x666d71,
            color3: 0x8e9599,
            color4: 0x3b3f42,
            color5: 0x4b5154,
            color6: 0x8e9599
        }));
        // Bronze
        _gradients.push(GradientColors({
            color1: 0x552517,
            color2: 0xad5331,
            color3: 0xe37144,
            color4: 0x5e2a1a,
            color5: 0x844026,
            color6: 0xf38453
        }));
        // Silver
        _gradients.push(GradientColors({
            color1: 0x5e5e5e,
            color2: 0xc1c1c1,
            color3: 0xd9d9d9,
            color4: 0x707070,
            color5: 0x8a8a8a,
            color6: 0xefefef
        }));
        // Gold
        _gradients.push(GradientColors({
            color1: 0x957639,
            color2: 0xe3bc7a,
            color3: 0xfed594,
            color4: 0xa98641,
            color5: 0xc19d59,
            color6: 0xffdda7
        }));
        // Obsidian
        _gradients.push(GradientColors({
            color1: 0x0c0c0c,
            color2: 0x303030,
            color3: 0x464646,
            color4: 0x161616,
            color5: 0x1e1e1e,
            color6: 0x3f3f3f
        }));
        // Pearl
        _gradients.push(GradientColors({
            color1: 0xccc6b7,
            color2: 0xeee8db,
            color3: 0xe5dfd3,
            color4: 0xfffdf5,
            color5: 0xe5dfd3,
            color6: 0xfffdf5
        }));
        // Amber
        _gradients.push(GradientColors({
            color1: 0x5a2200,
            color2: 0xb55e09,
            color3: 0xcf6100,
            color4: 0xfb9d00,
            color5: 0xcf6100,
            color6: 0xfb9d00
        }));
        // Amethyst
        _gradients.push(GradientColors({
            color1: 0x1a0035,
            color2: 0x400087,
            color3: 0x5300b1,
            color4: 0x8236ff,
            color5: 0x5300b1,
            color6: 0x8236ff
        }));
        // Emerald
        _gradients.push(GradientColors({
            color1: 0x001b18,
            color2: 0x00503d,
            color3: 0x006c51,
            color4: 0x3ac07d,
            color5: 0x006c51,
            color6: 0x3ac07d
        }));
        // Ruby
        _gradients.push(GradientColors({
            color1: 0x3b000f,
            color2: 0x6e0016,
            color3: 0xbc0d25,
            color4: 0xff5843,
            color5: 0xbc0d25,
            color6: 0xff5843
        }));
        // Sapphire
        _gradients.push(GradientColors({
            color1: 0x001154,
            color2: 0x002899,
            color3: 0x0037b4,
            color4: 0x0090ff,
            color5: 0x0037b4,
            color6: 0x0090ff
        }));
        // Diamond
        _gradients.push(GradientColors({
            color1: 0xa3faf9,
            color2: 0xedfffe,
            color3: 0x00e0f7,
            color4: 0x94fff5,
            color5: 0x00e0f7,
            color6: 0x94fff5
        }));
    }

    function setEverRiseRendererGlyph(address contractAddress) external onlyOwner {
        everRiseRendererGlyph = IEverRiseRendererGlyph(contractAddress);

        emit SetEverRiseRendererGlyph(contractAddress);
    }
    function setEverRiseNftStakes(address contractAddress) external onlyOwner {
        everRiseNftStakes = InftEverRise(contractAddress);

        emit SetEverRiseNftStakes(contractAddress);
    }

    function contractURI() external pure returns (string memory) {
        // Opensea contract details
        return "https://data.everrise.com/data/nftstakes.json";
    }


    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        if (address(everRiseNftStakes) == address(0)) revert NotSetup();
        //if (address(everRiseNftStakes) == _msgSender()) revert CallerNotApproved();

        return
            string(
                abi.encodePacked(
                    'data:application/json;base64,',
                    Base64.encode(getJson(_tokenId))
                )
            );
    }
    function getJson(uint256 nftId) private view returns (bytes memory) {
        StakingDetails memory stake = everRiseNftStakes.getNftData(nftId);

        string memory image = Base64.encode(getNtfSvg(stake));
        bytes memory attributes = getAttributes(stake);

        uint256 locked = stake.initialTokenAmount - stake.withdrawnAmount;
        bytes memory header = getHeader(locked, stake.numOfMonths, stake.withdrawnAmount > 0);

        return bytes(
            abi.encodePacked(
                header,
                image,
                attributes
            )
        );
    }
    function getHeader(uint256 locked, uint8 numOfMonths, bool isBroken) private view returns (bytes memory) {
        (bytes memory name,) = amountToAnimal(locked);
        
        return bytes(
            abi.encodePacked(
                '{"name":"',
                isBroken ? 'Broken ' : '',
                monthsToType(numOfMonths),
                " ",
                name,
                '", "external_url": "https://app.everrise.com/everstake/", "description":"EverRise Staking NFTs are Vote Escrowed (ve) EverRise weighted governance tokens which generate rewards with a market driven yield curve, based of the transaction volume of EverRise trades and veEverRise sales.", "image": "',
                'data:image/svg+xml;base64,'
            ));
    }

    function getAttributes(StakingDetails memory stake) private view returns (bytes memory) {
        uint256 locked = stake.initialTokenAmount - stake.withdrawnAmount;
        (bytes memory name, bytes memory denomination) = amountToAnimal(locked);
        
        return bytes(
            abi.encodePacked(
                '", "attributes": [',
                generateAttibutes1(stake.nftId, stake.withdrawnAmount > 0, name, denomination),
                generateAttibutes2(locked, stake.numOfMonths),
                generateAttibutes3(stake.numOfMonths, stake.withdrawnAmount, stake.initialTokenAmount, stake.depositTime, stake.achievementClaimed == _TRUE8),
                ']}'
            )
        );
    }

    function getChain() private view returns (bytes memory) {
        uint256 chainid = block.chainid;
        if (chainid == 1) return "Ethereum";
        if (chainid == 3) return "Ropsten";
        if (chainid == 4) return "Rinkeby";
        if (chainid == 25) return "Cronos";
        if (chainid == 56) return "BNB Chain";
        if (chainid == 97) return "BNB Testnet";
        if (chainid == 137) return "Polygon";
        if (chainid == 250) return "Fantom";
        if (chainid == 321) return "KuCoin Community";
        if (chainid == 43114) return "Avalanche";
        if (chainid == 80001) return "Polygon Testnet";
        if (chainid == 1666600000) return "Harmony";
        return "Unknown";
    }

    function generateAttibutes1(uint32 nftId, bool isBroken, bytes memory name, bytes memory denomination) private view returns (bytes memory) {
        return bytes(
            abi.encodePacked(
                '{"trait_type": "Generation","value": "Genesis"},{"trait_type": "Reward", "value": "Volume Based"},{"trait_type": "State","value": "',
                isBroken ? 'Broken ' : 'Whole',
                '"},{"trait_type": "Denomination","value": "',
                denomination,
                '"},{"trait_type": "Chain","value": "',
                getChain(),
                '"},{"display_type": "number","trait_type": "id","value": ',
                toString(nftId),
                '},{"trait_type": "Collection","value": "',
                name,
                '"},'
            )
        );
    }

    function generateAttibutes2(uint256 locked, uint256 numOfMonths) private view returns (bytes memory) {
        return bytes(
            abi.encodePacked(
                '{"trait_type": "Strength","value": "',
                monthsToType(numOfMonths),
                '"},{"display_type": "boost_percentage","trait_type": "Reward Boost","value": ',
                toString(numOfMonths * 100 / 12),
                ', "max_value": 300 },{"display_type": "number", "trait_type": "Escrow Months","value": ',
                toString(numOfMonths),
                ', "max_value": 36 },{"display_type": "number","trait_type": "Escrowed RISE","value": ',
                toString(locked / 10**18),
                '},{"display_type": "number","trait_type": "Vote Escrowed Weight","value": ',
                toString(locked * numOfMonths / 10**18),
                '},'
            )
        );
    }

    function generateAttibutes3(uint256 numOfMonths, uint256 withdrawnAmount, uint256 initialTokenAmount, uint256 depositTime, bool claimed) private pure returns (bytes memory) {
        (uint256 year,,,,,) = BokkyPooBahsDateTimeLibrary.timestampToDateTime(depositTime);
        return bytes(
            abi.encodePacked(
                '{"display_type": "boost_percentage","trait_type": "Health","value": ',
                toString(100 - withdrawnAmount * 100 / initialTokenAmount),
                ', "max_value": 100},{"display_type": "date","trait_type": "Start Date","value": ',
                toString(depositTime),
                '},{"display_type": "date","trait_type": "Unlock Date","value": ',
                toString(numOfMonths * 30 days + depositTime),
                '},{"display_type": "number","trait_type": "Year","value": "',
                toString(year),
                '"},{"trait_type": "Achievement Claimed","value": ',
                claimed ? '"True"}' : '"False"}'
            )
        );
    }

    bytes[12] private _collection = [
        bytes("Iron"), 
        "Bronze",
        "Silver",
        "Gold",
        "Obsidian",
        "Pearl",
        "Amber",
        "Amethyst",
        "Emerald",
        "Ruby",
        "Sapphire",
        "Diamond"
    ];

    bytes[13] private _colors = [
        bytes("#8e9599"), 
        "#f38453",
        "#efefef",
        "#ffe3b7",
        "#5e5e5e",
        "#fffef8",
        "#fb9d00",
        "#843dff",
        "#3ac07d",
        "#e7523f",
        "#0090ff",
        "#00e0f7"
    ];

    struct GradientColors{
        bytes3 color1;
        bytes3 color2;
        bytes3 color3;
        bytes3 color4;
        bytes3 color5;
        bytes3 color6;
    }

    GradientColors private _gradientDark = GradientColors({
        color1: 0xff9d32,
        color2: 0xca1630,
        color3: 0x003077,
        color4: 0x00183e,
        color5: 0x0a1b50,
        color6: 0x080d29
    });

    GradientColors private _gradientRising = GradientColors({
        color1: 0x080d29,
        color2: 0x0a1b51,
        color3: 0xcb1c3b,
        color4: 0xff9d32,
        color5: 0xca1b3b,
        color6: 0xff9d32
    });

    bytes[13] private _months = [
        bytes(""),
        "January", 
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
    ];

    function toString(uint256 value) private pure returns (bytes memory output)
    {
        if (value == 0)
        {
            return "0";
        }
        uint256 remaining = value;
        uint256 length;
        while (remaining != 0)
        {
            length++;
            remaining /= 10;
        }
        output = new bytes(length);
        uint256 position = length;
        remaining = value;
        while (remaining != 0)
        {
            output[--position] = bytes1(uint8(48 + remaining % 10));
            remaining /= 10;
        }
    }

    function toCommaString(uint256 value) private pure returns (bytes memory output)
    {
        if (value == 0)
        {
            return "0";
        }
        uint256 remaining = value;
        uint256 length;
        while (remaining != 0)
        {
            length++;
            remaining /= 10;
        }
        
        // Add the commas
        uint256 commas = (length - 1) / 3;
        length += commas;

        output = new bytes(length);
        uint256 position = length;
        uint256 toComma = 3;
        remaining = value;
        while (remaining != 0)
        {
            output[--position] = bytes1(uint8(48 + remaining % 10));
            remaining /= 10;

            if (commas > 0) {
                toComma--;
                if (toComma == 0) {
                    toComma = 3;
                    commas--;
                    output[--position] = ',';
                }
            }
        }

    }

    function monthsToType(uint256 months) private view returns (bytes memory) {
        if (months <= _collection.length) {
            return bytes(_collection[months - 1]);
        }

        if (months == 24) {
            return "Dark";
        }
        if (months == 36) {
            return "Rising";
        }

        return "Corrupted";
    }
    
    function amountToAnimal(uint256 threshold) private pure returns (bytes memory name, bytes memory denomination) {
      if (threshold > (250_000_000 - 1) * 10**18) {
          name = 'Kraken';
          denomination = '250M';
      } else if (threshold > (100_000_000 - 1) * 10**18) {
          name = 'Megalodon';
          denomination = '100M';
      } else if (threshold > (50_000_000 - 1) * 10**18) {
           name = 'Whale';
          denomination = '50M';
      } else if (threshold > (25_000_000 - 1) * 10**18) {
          name = 'Orca';
          denomination = '25M';
      } else if (threshold > (10_000_000 - 1) * 10**18) {
          name = 'Shark';
          denomination = '10M';
      } else if (threshold > (5_000_000 - 1) * 10**18) {
          name = 'Narwhal';
          denomination = '5M';
      } else if (threshold > (1_000_000 - 1) * 10**18) {
          name = 'Dolphin';
          denomination = '1M';
      } else if (threshold > (500_000 - 1) * 10**18) {
          name = 'Stingray';
          denomination = '500k';
      } else if (threshold > (100_000 - 1) * 10**18) {
          name = 'Swordfish';
          denomination = '100k';
      } else if (threshold > (50_000 - 1) * 10**18) {
          name = 'Starfish';
          denomination = '50k';
      } else if (threshold > (10_000 - 1) * 10**18) {
          name = 'Seahorse';
          denomination = '10k';
      } else if (threshold > (1_000 - 1) * 10**18) {
          name = 'Plankton';
          denomination = '1k';
      } else {
        name = 'Stake';
        denomination = '1';
      }
    }

    function getTextColor(uint8 months) private view returns (bytes memory) {
        if (months <= _collection.length) {
            return bytes(_colors[months - 1]);
        }

        if (months == 24) {
            return "#0d2346";
        }
        if (months == 36) {
            return "url(#grad3)";
        }

        return "#fff";
    }

    function getGradientColor(uint8 months) private view returns (GradientColors memory colors) {
        if (months <= _gradients.length) {
            return _gradients[months - 1];
        }

        if (months == 24) {
            return _gradientDark;
        }
        if (months == 36) {
            return _gradientRising;
        }
    }

    function bytes32ToString(bytes32 _bytes32) private pure returns (bytes memory) {
        bytes memory bytesArray = new bytes(6);
        for (uint8 i = 0; i < bytesArray.length; i++) {

            uint8 _f = uint8(_bytes32[i/2] & 0x0f);
            uint8 _l = uint8(_bytes32[i/2] >> 4);

            bytesArray[i] = toByte(_l);
            i = i + 1;
            bytesArray[i] = toByte(_f);
        }
        return bytesArray;
    }

    function toByte(uint8 _uint8) private pure returns (bytes1) {
        if(_uint8 < 10) {
            return bytes1(_uint8 + 48);
        } else {
            return bytes1(_uint8 + 87);
        }
    }

    function getGradients2(uint8 months) private view returns (bytes memory) {
        GradientColors memory colors = getGradientColor(months);

          return bytes(
            abi.encodePacked(
                '"/><stop offset="0.7" stop-color="#',
                bytes32ToString(colors.color4),
                '"/></linearGradient><linearGradient id="grad3" x1="0%" y1="0%" x2="100%" y2="0"><stop offset="0.2" stop-color="#',
                bytes32ToString(colors.color5),
                '"/><stop offset="1" stop-color="#',
                bytes32ToString(colors.color6),
                '"/></linearGradient>'
            )
        );
    }

    function getGradients1(uint8 months) private view returns (bytes memory) {
        GradientColors memory colors = getGradientColor(months);

          return bytes(
            abi.encodePacked(
                '<linearGradient id="grad" x1="150.61" y1="148.95" x2="457.27" y2="455.61" gradientTransform="matrix(1, 0, 0, -1, -25.57, 1873.39)" gradientUnits="userSpaceOnUse"><stop offset="0.2" stop-color="#',
                bytes32ToString(colors.color1),
                '"/><stop offset="1" stop-color="#',
                bytes32ToString(colors.color2),
                '"/></linearGradient><linearGradient id="grad2" x1="0%" y1="0%" x2="100%" y2="0" gradientTransform="rotate(-25 .5 .5)"><stop offset="0.2" stop-color="#',
                bytes32ToString(colors.color3)
            )
        );
    }


    function getNtfSvg(StakingDetails memory stake) private view returns (bytes memory) {
        uint256 locked = stake.initialTokenAmount - stake.withdrawnAmount;
        
        return bytes(
            abi.encodePacked(
                getNtfSvg1(stake.numOfMonths),
                getNtfSvg2(stake.depositTime, locked, stake.nftId, stake.numOfMonths, stake.withdrawnAmount > 0, stake.achievementClaimed == _TRUE8)
            )
        );
    }

    function getNtfSvg1(uint8 numOfMonths) private view returns (bytes memory) {
        return bytes(
            abi.encodePacked(
                '<svg id="NFTSVG" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 447 394.62"><defs><style>#NFTSVG { filter: drop-shadow(0px 8px 6px rgba(0, 0, 0, 0.4)); transform:scale(0.925); caret-color: transparent; } #bg { fill: url(#grad); } #circuit { fill: none; stroke-miterlimit: 10; stroke-width: 2.2px; stroke: url(#grad2); } #glyph { fill: url(#grad3); } #animaltxt1, #elem1 { font-size: 14px; } #amount1, #period1 { font-size: 12px; } text, #r1, #r2 {font-family: Trebuchet MS, sans-serif;font-size: 8px;line-height: 1;visibility: visible;font-weight: 500;letter-spacing: 1.5px;fill: ',
                getTextColor(numOfMonths),
                numOfMonths == 36 ? ';} #enddate, #endtime, #period2, #elem2 { fill: #cb2f3a; } #id, #chain, #animaltxt2, #amount2{ fill: #ff9d32; } #title, #everrise, #version1, #version2{ fill: #e25637; }</style>' : ';}</style>',
                getGradients1(numOfMonths),
                getGradients2(numOfMonths)
            )
        );
    }

    function getNtfSvg2(uint256 timestamp, uint256 amount, uint256 nftId, uint8 numOfMonths, bool isBroken, bool isClaimed) private view returns (bytes memory) {
        return bytes(
            abi.encodePacked(
                '</defs>',
                getNtfMarkup(timestamp, amount, nftId, numOfMonths, isBroken, isClaimed),
                '</svg>'
            )
        );
    }

    function getNtfMarkup(uint256 timestamp, uint256 amount, uint256 nftId, uint256 numOfMonths, bool isBroken, bool isClaimed) private view returns (bytes memory) {
        return bytes(
            abi.encodePacked(
                getNftPaths(amount, isClaimed),
                '<g id="txt">',
                    getNtfDateText(timestamp),
                    getNtfSizeText(amount),
                    getNtfStrengthText(nftId),
                    getNtfStrengthText(numOfMonths, isBroken),
                '</g>'
            )
        );
    }

    function getNftPaths(uint256 amount, bool isClaimed) private view returns (bytes memory){
        return bytes(
            abi.encodePacked(
                '<g id="paths"><path id="bg" data-name="bg" d="M156.37,1754.42,58.62,1585.11a28,28,0,0,1,0-28l97.75-169.31a28,28,0,0,1,24.25-14h195.5a28,28,0,0,1,24.25,14l97.75,169.31a28,28,0,0,1,0,28l-97.75,169.31a28,28,0,0,1-24.25,14H180.62A28,28,0,0,1,156.37,1754.42Z" transform="translate(-54.87 -1373.5)"/><path id="circuit" d="M393.34,1407.24a5.5,5.5,0,1,1-5.5-5.49A5.5,5.5,0,0,1,393.34,1407.24Zm-199.45-16.49a5.5,5.5,0,1,0,5.5,5.5,5.5,5.5,0,0,0-5.5-5.5Zm-110,162a5.5,5.5,0,1,0,5.5,5.5,5.5,5.5,0,0,0-5.5-5.5Zm87,173a5.5,5.5,0,1,0,5.5,5.5,5.51,5.51,0,0,0-5.5-5.5Zm196,15a5.5,5.5,0,1,0,5.5,5.5,5.5,5.5,0,0,0-5.5-5.5Zm106-162a5.5,5.5,0,1,0,5.49,5.49,5.49,5.49,0,0,0-5.49-5.49Zm-389.42,4,93.29-162h73.67l13-13H172.89m-86.48,145,76-132H176.7m-4.81-13H359.35l44,77,18,5,39,66-37,64,5,18-48,83-72.73,0-13.25,13h-93l-36-63-19-6-47.91-82,44.91-78-5-17.58m60.44-91.39H352.35l9.11,15.64m5.59-16,54.29,94.31m46,54-76.62-132m73.91,127.32,2.71,4.65-11,19M167.47,1726.28,91.41,1594.7l7.08-12m47.88,81.94,46,80M427.56,1639l46.27-79.82m-3,29.27-75.36,132.19H377.54m-84.67,13H389m-27.14,12H208.38L199,1729.4" transform="translate(-54.87 -1373.8)"/>',
                isClaimed ? '' : '<path id="r2" d="M372.47,1724.6a3.55,3.55,0,0,1,2.56-1.27,3.76,3.76,0,0,1,3.2,2.23,3.47,3.47,0,0,1,.21,1.91,3.41,3.41,0,0,1-1,1.89,3.46,3.46,0,0,1-1.35.81c-.29-1.44-.59-2.88-.88-4.32.64.49,1.27,1,1.9,1.49l.16-.17-2.21-2.81-2.21,2.81.16.17,1.91-1.49c-.3,1.43-.59,2.87-.89,4.31a3.2,3.2,0,0,1-1.12-.6,3.43,3.43,0,0,1-1.23-2,3.53,3.53,0,0,1-.05-.92A3.42,3.42,0,0,1,372.47,1724.6Z" transform="translate(-54.87 -1373.8)"/>',
                '<path id="r1" d="M271.59,1713.21a8.18,8.18,0,0,1,10.68-1.31,8.13,8.13,0,0,1,3.41,8.09,8,8,0,0,1-2.39,4.48,8.23,8.23,0,0,1-3.19,1.9q-1-5.1-2.08-10.21c1.5,1.16,3,2.35,4.49,3.52l.38-.38c-1.74-2.21-3.48-4.43-5.23-6.64l-5.22,6.64.39.38,4.5-3.52c-.69,3.4-1.4,6.8-2.09,10.19a7.84,7.84,0,0,1-2.66-1.41,8.16,8.16,0,0,1-2.89-4.73,8.74,8.74,0,0,1-.13-2.17A8.1,8.1,0,0,1,271.59,1713.21Z" transform="translate(-54.87 -1373.8)"/><path id="glyph" d="',
                everRiseRendererGlyph.glyph(amount),
                '/></g>'
            )
        );
    }
    
    function getNtfDateText(uint256 timestamp) private view returns (bytes memory) {
        (uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute,) = 
            BokkyPooBahsDateTimeLibrary.timestampToDateTime(timestamp);
        /*
        <text id="enddate" transform="translate(77.5 118) rotate(-60)" text-anchor="middle">23 APRIL 2022</text>
        <text id="endtime" transform="translate(63 168.8) rotate(-60)" text-anchor="middle">16:34 UTC</text>
        */
        return bytes(
            abi.encodePacked(
                '<text id="enddate" transform="translate(77.5 118) rotate(-60)" text-anchor="middle">',
                toString(day),
                ' ',
                toUpper(_months[month]),
                ' ',
                toString(year),
                '</text><text id="endtime" transform="translate(63 168.8) rotate(-60)" text-anchor="middle">',
                toString(hour),
                ':',
                toString(minute),
                ' UTC</text>')
        );
    }

    function getNtfSizeText(uint256 amount) private pure returns (bytes memory) {
        /*
        <text id="amount1" transform="translate(221.26 313.47)" text-anchor="middle">100,000,000 RISE</text>
        <text id="amount2" transform="translate(375.1 280) rotate(-60)" text-anchor="middle">100,000,000 RISE</text>
        <text id="animaltxt2" transform="translate(395.4 219) rotate(-60)" text-anchor="middle">STAKE</text>
        <text id="animaltxt1" transform="translate(220.96 88.5)" text-anchor="middle">STAKE</text>
        */
        (bytes memory animal, ) = amountToAnimal(amount);
        bytes memory size = toCommaString(amount / 10**18);
        animal = toUpper(animal);

        return bytes(
            abi.encodePacked(
                '<text id="amount1" transform="translate(221.26 313.47)" text-anchor="middle">',
                size,
                ' RISE</text><text id="amount2" transform="translate(375.1 280) rotate(-60)" text-anchor="middle">',
                size,
                ' RISE</text><text id="animaltxt2" transform="translate(395.4 219) rotate(-60)" text-anchor="middle">',
                animal,
                '</text><text id="animaltxt1" transform="translate(220.96 88.5)" text-anchor="middle">',
                animal,
                '</text>'
            )
        );
    }
    
    function getNtfStrengthText(uint256 numOfMonths, bool isBroken) private view returns (bytes memory) {
        /*
        <text id="elem1" transform="translate(220.96 72)" text-anchor="middle">BROKEN SAPPHIRE</text>
        <text id="elem2" transform="translate(119.4 332) rotate(60)" text-anchor="middle">SAPPHIRE</text>
        <text id="period1" transform="translate(221.26 329.68)" text-anchor="middle">11 MONTHS</text>
        <text id="period2" transform="translate(77 285) rotate(60)" text-anchor="middle">11 MONTHS</text>
        */
        bytes memory strength = toUpper(monthsToType(numOfMonths));
        bytes memory size = toString(numOfMonths);

        return bytes(
            abi.encodePacked(
                '<text id="elem1" transform="translate(220.96 72)" text-anchor="middle">',
                isBroken ? 'BROKEN ' : '' ,
                strength,
                '</text><text id="elem2" transform="translate(119.4 332) rotate(60)" text-anchor="middle">',
                strength,
                '</text><text id="period1" transform="translate(221.26 329.68)" text-anchor="middle">',
                size,
                ' MONTHS</text><text id="period2" transform="translate(77 285) rotate(60)" text-anchor="middle">',
                size,
                ' MONTHS</text>'
            )
        );
    }
    
    function getNtfStrengthText(uint256 nftId) private view returns (bytes memory) {
        /*
        <text id="id" transform="translate(326.85 66.78) rotate(60)" text-anchor="middle">#000000001</text>
        <text id="chain" transform="translate(366 108.4) rotate(60)" text-anchor="middle">ETHEREUM</text>
        <text id="everrise" transform="translate(223 368.8)" text-anchor="middle">EVERRISE</text>
        <text id="version2" transform="translate(288.94 356.5)" text-anchor="middle">GENESIS</text>
        <text id="version1" transform="translate(153.33 43.5)" text-anchor="middle">GENESIS</text>
        <text id="title" transform="translate(220.65 31)" text-anchor="middle">RISE STAKE</text>
        */
        bytes memory issueNumber = toString(nftId);
        bytes memory chain = getChain();

        return bytes(
            abi.encodePacked(
                '<text id="id" transform="translate(326.85 66.78) rotate(60)" text-anchor="middle">#',
                issueNumber,
                '</text><text id="chain" transform="translate(366 108.4) rotate(60)" text-anchor="middle">',
                toUpper(chain),
                '</text><text id="everrise" transform="translate(223 368.8)" text-anchor="middle">EVERRISE</text><text id="version2" transform="translate(288.94 356.5)" text-anchor="middle">GENESIS</text><text id="version1" transform="translate(153.33 43.5)" text-anchor="middle">GENESIS</text><text id="title" transform="translate(220.65 31)" text-anchor="middle">RISE STAKE</text>'
            )
        );
    }

    function toUpper(bytes memory _base) private pure returns (bytes memory) {
        for (uint i = 0; i < _base.length; i++) {
            bytes1 b = _base[i];
            if (b >= 0x61 && b <= 0x7A) {
                _base[i] = bytes1(uint8(b) - 32);
            }
        }
        return _base;
    }
}