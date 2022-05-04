

module.exports = async({ getNamedAccounts, deployments }) => {
    const { deploy } = deployments
    const { deployer} = await getNamedAccounts()

    const rewardTokens = await deploy("RewardToken", {
        from: deployer,
        args: [],
        log: true,
    })
}

module.exports.tags = ["all", "rewardToken"]