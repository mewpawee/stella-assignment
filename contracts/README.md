# Explaination

## StakingRewarder
We could calculate the current accumulatedRewardPerShare from the following formula

$$rewardPerShare = rewardRatePerSec \cdot \frac{deltaTime}{totalShare}$$

$$accumulatedRewardPerShare_n = rewardPerShare_1 + rewardPerShare_2 + rewardPerShare_3 + \cdots + rewardPerShare_n \hspace{10pt} where \ n >= 1$$

$$accumulatedRewardPerShare_{n,m} = rewardPerShare_m - rewardPerShare_n \hspace{10pt} where \ m > n >= 1$$

$$userRewardAmount_{n,m} = userShare * accumulatedRewardPerShare_{n,m}  \hspace{10pt} where \ m > n >= 1$$

This approach works because the $rewardPerShare$ needs to be calculated with delta time (the time difference between the current and the last interaction) when interactions that change the $totalShare$ occur, such as `deposit` or `withdraw`. The difference between the current accumulatedRewardPerShare ($accumulatedRewardPerShare_m$) and the user's last accumulatedRewardPerShare ($accumulatedRewardPerShare_n$) represents the reward per share for that user in that period ($accumulatedRewardPerShare_{n,m}$). Multiplying this rate by the current $userShare$ will give the amount of reward tokens that should be distributed to the user within that time frame.