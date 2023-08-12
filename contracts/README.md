# Explaination

## StakingRewarder
We could calculate the current accumulatedRewardPerShare from the following formula

$$rewardPerShare = rewardRatePerSec \cdot \frac{deltaTime}{totalShare}$$

$$accumulatedRewardPerShare_n = rewardPerShare_1 + rewardPerShare_2 + rewardPerShare_3 + \cdots + rewardPerShare_n$$

At the beginning of the StakingRewarder contract, the user never deposit the token before and some point a user decide to deposit. Since no one deposit before, the total share is zero then the accumulatedReward per share can't calculated, so only the current timestamp is recorded as lastTimestamp. At the end of the function, totalShare and user's balance also be recorded as a reference for the next updateReward calculation.
When the next user deposit, using the previous totalShare, last timestamp as a reference, now the accumulatedRewardPerShare at n = 1 could be calculate. The current accumulatedRewardPerShare (n = 1) will be record for this user as a reference when the user interact with the contract again (for the first user, user's accumulatedRewardPerShare is 0). When the second user interact with the contract again, the reward will be calculated by the number of user's share time with the difference between the current accumulatedRewardPerShare and the user's accumulatedRewardPerShare. The current accumulateRewardPerShare then will be use as a user's new reference for the next calculation.

This appoach is working since the the accumulatedRewardPerShare will growth with interactions (deposit or withdraw). The contract need to track the previous position of the user in this formula in order to calculate the gap between the user's current accumulatedRewardPerShare and the previous one, which represent the reward rate per share for this user. This rate time user's share will equal to the amount of the reward token should distribute to the user.