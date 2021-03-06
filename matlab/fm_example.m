clear all; close all;

%% Load data

% work with toy datasets for now
data = dlmread('../data/toy_matrix.txt');
dataset_size = size(data, 1);

% separate train_test sets
num_test = round(dataset_size * 0.1);
test_data = data(1:num_test, :);
train_data = data(num_test+1:end, :);


%% Intialize model parameters
num_products = max(data(:, 1));
num_users = max(data(:, 2));
latent_size = 10;
lambda = 0.05; % regularization constant

% initialize parameters
theta = 0.001*randn((num_products + num_users)*latent_size, 1);

%% if using fmincg
% options = optimset('GradObj', 'on', 'MaxIter', 50);
% [opt_theta, cost] = fmincg ( @(t) factorization_cost(t, num_products, num_users, ...
%   latent_size, lambda, train_data), theta, options);

%% if using minFunc
options.Method = 'lbgfs';
options.maxIter = 500;	
options.display = 'on';
options.DerivativeCheck = 'on';
addpath minFunc/
[opt_theta, cost] = minFunc ( @(t) factorization_cost(t, num_products, num_users, ...
    latent_size, lambda, train_data), theta, options);
                              

%% Results
p = reshape(opt_theta(1:num_products*latent_size), num_products, latent_size);
u = reshape(opt_theta(num_products*latent_size + 1: end), num_users, latent_size);

train_product_idx = train_data(:, 1);
train_user_idx = train_data(:, 2);
train_ratings = train_data(:, 3);

test_product_idx = test_data(:, 1);
test_user_idx = test_data(:, 2);
test_ratings = test_data(:, 3);

predicted_train_ratings = sum(p(train_product_idx, :).*u(train_user_idx, :), 2);
predicted_test_ratings = sum(p(test_product_idx, :).*u(test_user_idx, :), 2);

% rmse
train_rmse = sqrt(mean((predicted_train_ratings - train_ratings).^2))
test_rmse = sqrt(mean((predicted_test_ratings - test_ratings).^2))

