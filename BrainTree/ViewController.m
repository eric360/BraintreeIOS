//
//  ViewController.m
//  BrainTree
//
//  Created by Eric Hth Perso on 19/08/15.
//  Copyright (c) 2015 Eric Hth Perso. All rights reserved.
//

#import "ViewController.h"
#import <Braintree/Braintree.h>
@interface ViewController () <BTDropInViewControllerDelegate>
@property (nonatomic, strong) Braintree *braintree;
@end
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // TODO: Switch this URL to your own authenticated API
//    NSURL *clientTokenURL = [NSURL URLWithString:@"https://braintree-sample-merchant.herokuapp.com/client_token"];
//
    NSURL *clientTokenURL = [NSURL URLWithString:@"https://fathomless-sea-8038.herokuapp.com/client_token"];
    NSMutableURLRequest *clientTokenRequest = [NSMutableURLRequest requestWithURL:clientTokenURL];
    [clientTokenRequest setValue:@"text/plain" forHTTPHeaderField:@"Accept"];
    [NSURLConnection
     sendAsynchronousRequest:clientTokenRequest
     queue:[NSOperationQueue mainQueue]
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         // TODO: Handle errors in [(NSHTTPURLResponse *)response statusCode] and connectionError
         NSString *clientToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         
         // Initialize `Braintree` once per checkout session
         self.braintree = [Braintree braintreeWithClientToken:clientToken];
         NSLog(@"%@",clientToken);
     }];
}

- (IBAction)tappedMyPayButton {
    
    // If you haven't already, create and retain a `Braintree` instance with the client token.
    // Typically, you only need to do this once per session.
    //self.braintree = [Braintree braintreeWithClientToken:aClientToken];
    
    // Create a BTDropInViewController
    BTDropInViewController *dropInViewController = [self.braintree dropInViewControllerWithDelegate:self];
    // This is where you might want to customize your Drop in. (See below.)
    
    // The way you present your BTDropInViewController instance is up to you.
    // In this example, we wrap it in a new, modally presented navigation controller:
    dropInViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                          target:self
                                                                                                          action:@selector(userDidCancelPayment)];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dropInViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)userDidCancelPayment {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dropInViewController:(__unused BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod {
    [self postNonceToServer:paymentMethod.nonce]; // Send payment method nonce to your server
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewControllerDidCancel:(__unused BTDropInViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)postNonceToServer:(NSString *)paymentMethodNonce {
    // Update URL with your server
    NSURL *paymentURL = [NSURL URLWithString:@"https://your-server.example.com/payment-methods"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:paymentURL];
    request.HTTPBody = [[NSString stringWithFormat:@"payment_method_nonce=%@", paymentMethodNonce] dataUsingEncoding:NSUTF8StringEncoding];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               // TODO: Handle success and failure
                           }];
}

@end
