import gymnasium as gym
import numpy as np
import matplotlib.pyplot as plt
import pickle

def run(episodes, is_training=True, render=False):
    # Set map_name to "8x8" for the larger Frozen Lake environment
    env = gym.make('FrozenLake-v1', map_name="8x8", is_slippery=True, render_mode='human' if render else None)

    if is_training:
        # Initialize a 64x4 array for Q-learning (64 states, 4 actions)
        q = np.zeros((env.observation_space.n, env.action_space.n))
    else:
        # Load the Q-table from a file
        with open('frozen_lake8x8.pkl', 'rb') as f:
            q = pickle.load(f)

    # Higher learning rate and discount factor for faster convergence
    learning_rate_a = 0.99
    discount_factor_g = 0.99
    epsilon = 0.9  # Initial exploration rate
    epsilon_decay_rate = 0.00005  # Slow epsilon decay for exploration-exploitation balance
    rng = np.random.default_rng()  # Random number generator

    rewards_per_episode = np.zeros(episodes)

    for i in range(episodes):
        state = env.reset()[0]  # Get the initial state
        terminated = False
        truncated = False

        while not terminated and not truncated:
            # With a lower epsilon, there's less random exploration
            if is_training and rng.random() < epsilon:
                action = env.action_space.sample()  # Random action
            else:
                action = np.argmax(q[state, :])  # Choose the best action from Q-table

            # Take the action and get the result
            new_state, reward, terminated, truncated, _ = env.step(action)

            if is_training:
                # Update Q-table using Q-learning
                q[state, action] = q[state, action] + learning_rate_a * (
                    reward + discount_factor_g * np.max(q[new_state, :]) - q[state, action]
                )

            state = new_state  # Update the state

        epsilon = max(epsilon - epsilon_decay_rate, 0)  # Slow epsilon decay

        if reward == 1:  # If the goal is reached
            rewards_per_episode[i] = 1

    env.close()

    # Plotting the cumulative rewards
    sum_rewards = np.zeros(episodes)
    for t in range(episodes):
        sum_rewards[t] = np.sum(rewards_per_episode[max(0, t - 100):(t + 1)])

    plt.plot(sum_rewards)
    plt.title("Cumulative Rewards Over Time")
    plt.xlabel("Episode")
    plt.ylabel("Cumulative Rewards")
    plt.show()  # Display the plot

    if is_training:
        # Save the Q-table for future use
        with open("frozen_lake8x8.pkl", "wb") as f:
            pickle.dump(q, f)

# Running the code
if __name__ == '__main__':
    run(2, is_training=True, render=True)  # Training without rendering for faster execution
