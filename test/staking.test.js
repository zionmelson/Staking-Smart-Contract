const { ethers } = require("hardhat")
const { moveBlocks } = require("../utils/move-blocks")
const { moveTime } = require("../utils/move-time")

const SEC_IN_DAY = 86400
const SEC_IN_YEAR = 31449600

describe("Staking test", async () => {
    let staking, rewardToken, deployer, stakeAmount

    beforeEach(async () => {
        const accounts = await ethers.getSigners()
        deployer = accounts[0]
        await deployments.fixture(["all"])
        staking = await ethers.getContract("Staking")
        rewardToken = await ethers.getContract("RewardToken")
        stakeAmount = ethers.utils.parseEther("10000")
    })

    it("Allows users to stake and claim rewards", async () => {
        await rewardToken.approve(staking.address, stakeAmount)
        await staking.stake(stakeAmount)
        const startEarned = await staking.earned(deployer.address)
        console.log(`Starting Earned ${startEarned}`)

        await moveTime(SEC_IN_DAY)
        await moveBlocks(1)

        const endEarned = await staking.earned(deployer.address)
        console.log(`Ending Eanred ${endEarned}`)

        // one token = 1000000000000000000
        // earn(1)day= 8640000
        // earn(1)yr = 3144960000
    })
})