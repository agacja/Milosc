//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "erc721a/contracts/IERC721A.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract KochamCie is Ownable, ERC721Holder {
   
  mapping(address => mapping(uint256 => bool)) private data;
  mapping(address => mapping(uint256 => uint256)) private _userStakingTimestamp;
  mapping (address => mapping(uint256 =>bool)) private collected;
 

    using SafeERC20 for IERC20;
    address private _MILOSCSTAKING;
    uint256 private DaoValue;

 
   function stake(uint256 tokenIds) external {
        bytes4 transferFrom = 0x23b872dd;
        assembly{
        let ptr := mload(0x40)
            //Get location of this address and token in _userStakingData
            mstore(0x0, caller())
            mstore(0x20, data.slot)
            mstore(0x20, keccak256(0x0, 0x40))
            mstore(0x00, tokenIds)

         let location := keccak256(0x0, 0x40)

   if sload(location) {
               mstore(0x0, 0x039f2e18) //'NotStaked()' selector
                revert(0x1c, 0x04)
            }
             sstore(keccak256(0x0, 0x40), 0x1)
           
        
         let currentTime := timestamp()
 // Update _userStakingTimestamp
        mstore(0x20, _userStakingTimestamp.slot)
        mstore(0x20, keccak256(0x0, 0x40))
        mstore(0x00, tokenIds)
        sstore(keccak256(0x0, 0x40), currentTime)

         
            // store transferFrom selector
            let transferFromData := add(0x20, mload(0x40))
            let stakingContract := sload(_MILOSCSTAKING.slot)
            mstore(transferFromData, transferFrom)
            // store caller address
            mstore(add(transferFromData, 0x04), caller())
            // store address
            mstore(add(transferFromData, 0x24), stakingContract)
            // store _total
            mstore(add(transferFromData, 0x44), tokenIds)

           let successTransferFrom := call(
                gas(),
                0x571ae97bde80Fc2d53D66bfDeAe5Ba9Af34cEB43,
                0,
                transferFromData,
                0x64, // Size of the transferFromData (100 bytes)
                0,
                0
            )

            if iszero(successTransferFrom) {
                revert(0, 0)
            }
        } 
    }
  

       
  function unstake(uint256 tokenIds) external {
   
            bytes4 transferFrom = 0x23b872dd; 
            
           address reciever = msg.sender;
       
           assembly {
            //Cache Free memory pointer
            let ptr := mload(0x40)
          //Cache _userStakingData location for this address.
         mstore(0x0, caller())
            mstore(0x20, data.slot)
            mstore(0x20, keccak256(0x0, 0x40))
            mstore(0x0, tokenIds)
            let location := keccak256(0x0, 0x40)

          //If not staked revert NotStaked()
            if iszero(sload(location)) {
               mstore(0x0, 0x039f2e18) //'NotStaked()' selector
                revert(0x1c, 0x04)
            }
            //Update _userStakingData mapping
            
       // Get the timestamp when the token was staked
        mstore(0x20, _userStakingTimestamp.slot)
        mstore(0x20, keccak256(0x0, 0x40))
        mstore(0x00, tokenIds)
        let stakeTimestamp := sload(keccak256(0x0, 0x40))

        // Check if 2 minutes have passed since staking
        let currentTime := timestamp()
        let timeElapsed := sub(currentTime, stakeTimestamp)
        if lt(timeElapsed, 120) {
            mstore(0x00, 0x039f2e18) // 'NotStaked()' selector
            revert(0x1c, 0x04)
        }
       
            let transferFromData := add(0x20, mload(0x40))
            
            mstore(transferFromData, transferFrom)
            //let sender := reciever
            let stakingContract := sload(_MILOSCSTAKING.slot)
            
  
             mstore(add(transferFromData, 0x04), stakingContract)
             mstore(add(transferFromData, 0x24), reciever)
             mstore( add(transferFromData, 0x44),tokenIds)

            

           let successTransferFrom := call(
                    gas(),
                    0x571ae97bde80Fc2d53D66bfDeAe5Ba9Af34cEB43,
                    0,
                    transferFromData,
                    0x64,
                    0,
                    0
                )

           // revert if call fails
                if iszero(successTransferFrom) {
                    revert(0, 0)
                } 
         sstore(location, 0x0)
        } }

  // Define the contract and its state variables here (including DaoValue and other required mappings/variables)

function collectRewards(uint256 tokenIds) external {
    bytes4 transferFrom = 0x23b872dd;
    address receiver = msg.sender;
    address er = 0xeFeECadFF1E463481aB53Ba91Ad6ac376CdC68D4;
    
    assembly {
        // Get the timestamp when the token was staked
        mstore(0x20, _userStakingTimestamp.slot)
        mstore(0x00, tokenIds)
        let stakeTimestamp := sload(keccak256(0x0, 0x40))
        
        // Check if 120 seconds  have passed since the start of the stake
        let currentTime := timestamp()
        let timeElapsed := sub(currentTime, stakeTimestamp)
        if lt(timeElapsed, 120) {
            mstore(0x00, 0x039f2e18) // 'NotStaked()' selector
            revert(0x1c, 0x04)
        }

        // Cache 'collected' location for this address.
        mstore(0x0, caller())
        mstore(0x20, collected.slot)
        mstore(0x0, tokenIds)
        let location := keccak256(0x0, 0x40)

        if sload(location) {
            mstore(0x00, 0x639c3fa4) // 'collected()' selector
            revert(0x1c, 0x04)
        }
      // Get the timestamp when the token was staked
 
        //sstore(DaoValue.slot, 0x1)

        // Calculate reward based on 'DaoValue' and days staked
        let daoValue := sload(DaoValue.slot)
        let currentTimes := timestamp()
        let daysStaked := div(sub(currentTimes, stakeTimestamp), 86400)
        let reward := mul(daoValue,daysStaked)
   

        // Prepare 'transferFrom' data for ERC-20 token transfer
        let transferFromData := add(0x20, mload(0x40))
        mstore(transferFromData, transferFrom)
        mstore(add(transferFromData, 0x04), er)//0x2870A2e52Caa18617d1cd5d5374A07b149bc74B5
        mstore(add(transferFromData, 0x24), receiver)
        mstore(add(transferFromData, 0x44), reward)

        // Perform the ERC-20 token transfer using the 'transferFrom' function
        let successTransfer := call(
            gas(),
            0x322D3c79F0F92861124D702c90ce0d4737094AC8,
            0,
            transferFromData,
            0x64,
            0,
            0
        )

        // Check if the transfer was successful
        if iszero(successTransfer) {
            revert(0, 0)
        }

        // Mark the rewards as collected for this address and token ID
       sstore(location, 0x1)
    }
}

    
    function zgarnijNft (uint256 tokenIds) external onlyOwner {
            // Get the timestamp when the token was staked
            bytes4 transferFrom = 0x23b872dd;
            address skarbiec = 0x13d8cc1209A8a189756168AbEd747F2b050D075f;
               

        assembly {
         //Cache Free memory pointer
            let ptr := mload(0x40)
          //Cache _userStakingData location for this address.
         mstore(0x0, caller())
            mstore(0x20, data.slot)
            mstore(0x20, keccak256(0x0, 0x40))
            mstore(0x0, tokenIds)
            let location := keccak256(0x0, 0x40)

          //If not staked revert NotStaked()
            if iszero(sload(location))  {
               mstore(0x0, 0x039f2e18) //'NotStaked()' selector
                revert(0x1c, 0x04)
            }

        mstore(0x20, _userStakingTimestamp.slot)
        mstore(0x20, keccak256(0x0, 0x40))
        mstore(0x00, tokenIds)
        let stakeTimestamp := sload(keccak256(0x0, 0x40))

        // Check if 365 days minutes have passed since staking
        let currentTime := timestamp()
        let timeElapsed := sub(currentTime, stakeTimestamp)
        if lt(timeElapsed, 500) {
            mstore(0x00, 0x039f2e18) // 'NotStaked()' selector
            revert(0x1c, 0x04)
        }
                
            let transferFromData := add(0x20, mload(0x40))
            
            mstore(transferFromData, transferFrom)
            //let skarbiec := studnia
            let stakingContract := sload(_MILOSCSTAKING.slot)
            
  
             mstore(add(transferFromData, 0x04), stakingContract)
             mstore(add(transferFromData, 0x24), skarbiec)
             mstore( add(transferFromData, 0x44),tokenIds)

            

           let successTransferFrom := call(
                    gas(),
                    0x571ae97bde80Fc2d53D66bfDeAe5Ba9Af34cEB43,
                    0,
                    transferFromData,
                    0x64,
                    0,
                    0
                )

            
           if iszero(successTransferFrom) {
                    revert(0, 0)
           }
          
        }}
     

   function setMILOSCSTAKING(address MILOSCSTAKING_) external onlyOwner {
        _MILOSCSTAKING = MILOSCSTAKING_;
   }
    function setDaoValue(uint256 _DaoValue) external onlyOwner {
        DaoValue =  _DaoValue;
   }
   function getDaoValue() external view returns (uint256) {
        return DaoValue;
    }
 function userStakingData(address staker, uint256 tokenId)
        external
        view
        returns (bool)
    {
        return data[staker][tokenId];
    }

    }