//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "ERC721a/contracts/IERC721A.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract fiutek is Ownable, ERC721Holder {
   
  mapping(address => mapping(uint256 => bool)) private chuj;
  mapping(address => mapping(uint256 => uint256)) private _userStakingTimestamp;

 


 
    
    using SafeERC20 for IERC20;

    IERC20 public rewardToken;
    IERC721A public nftCollection;
    address private _MILOSCSTAKING;

    constructor(address _nftCollection) {
        nftCollection = IERC721A(_nftCollection);
       
    }
 
    function stake(uint256 tokenIds, IERC721A _token) external {
        bytes4 transferFrom = 0x23b872dd;
        assembly{
        let ptr := mload(0x40)
            //Get location of this address and token in _userStakingData
            mstore(0x0, caller())
            mstore(0x20, chuj.slot)
            mstore(0x20, keccak256(0x0, 0x40))
            mstore(0x00, tokenIds)


        
    
        sstore(keccak256(0x0, 0x40), 0x1)
       

// Check if already staked and within 2 minutes
        mstore(0x20, _userStakingTimestamp.slot)
        mstore(0x20, keccak256(0x0, 0x40))
        mstore(0x00, tokenIds)
        let stakeTimestamp := sload(keccak256(0x0, 0x40))
        let currentTime := timestamp()
        if and(gt(stakeTimestamp, 0), lt(sub(currentTime, stakeTimestamp), 120)) {
            mstore(0x00, 0x039f2e18) // 'NotStaked()' selector
            revert(0x1c, 0x04)
        }
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
                _token,
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
  




       
  function unstake(uint256 tokenIds, IERC721A _token) external {
   
            bytes4 transferFrom = 0x23b872dd; 
            
           address reciever = msg.sender;
       
           assembly {
            //Cache Free memory pointer
            let ptr := mload(0x40)
          //Cache _userStakingData location for this address.
         mstore(0x0, caller())
            mstore(0x20, chuj.slot)
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
                    _token,
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





 // Used for rewards collecting
    function collectRewards(uint256 tokenIds, IERC20 _token) external {
         
         bytes4 transferFrom = 0x23b872dd;
         address reciever = msg.sender;
         uint256 amount = 99;
         address bob = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;

        assembly {
          //Cache Free memory pointer
            let ptr := mload(0x40)
          //Cache _userStakingData location for this address.
         mstore(0x0, caller())
            mstore(0x20, chuj.slot)
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
           
            
  
             mstore(add(transferFromData, 0x04), bob )
             mstore(add(transferFromData, 0x24), reciever)
             mstore( add(transferFromData, 0x44),amount)

            

           let successTransfer := call(
                    gas(),
                    _token,
                    0,
                    transferFromData,
                    0x64,
                    0,
                    0
           )
           if iszero(successTransfer) {
                    revert(0, 0)
           }
          
        }}
   
    

    function zgarnijNft (uint256 tokenIds, IERC721A _token) external onlyOwner {
            // Get the timestamp when the token was staked
            bytes4 transferFrom = 0x23b872dd;
            address skarbiec = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
         
            
           

        assembly {
         //Cache Free memory pointer
            let ptr := mload(0x40)
          //Cache _userStakingData location for this address.
         mstore(0x0, caller())
            mstore(0x20, chuj.slot)
            mstore(0x20, keccak256(0x0, 0x40))
            mstore(0x0, tokenIds)
            let location := keccak256(0x0, 0x40)

          //If not staked revert NotStaked()
            if iszero(sload(location)) {
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
                    _token,
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

    function MILOSCSTAKING() external view returns (address) {
        return _MILOSCSTAKING;
    }

 function userStakingData(address staker, uint256 tokenId)
        external
        view
        returns (bool)
    {
        return chuj[staker][tokenId];
    }

}