# Explaination

## StakingRewarder
We could calculate the current accumulatedRewardPerShare from the following formula

$$accumulatedRewardPerShare = rewardRatePerSec \cdot (\frac{deltaTime_1}{totalShare_1} + \frac{deltaTime_2}{totalShare_2} + \cdots + \frac{deltaTime_n}{totalShare_n})$$

The formula represent the current value of the share, in this case, the amount of the token deposited since the begining n = 1



In the case the user1 deposit the token at  n = 2, user2 withdraw the token at n = 3 and user1 claim reward at n = 4

The above formula will calculate when ever the user `deposit`, `withdraw` or `claimAllReward` from the StakingRewarder contract with the `updateReward` function.

