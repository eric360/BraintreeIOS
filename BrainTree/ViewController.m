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
    NSURL *clientTokenURL = [NSURL URLWithString:[Heroku serverUrl]];
    NSMutableURLRequest *clientTokenRequest = [NSMutableURLRequest requestWithURL:clientTokenURL];
    [clientTokenRequest setValue:@"text/plain" forHTTPHeaderField:@"Accept"];
    [NSURLConnection
     sendAsynchronousRequest:clientTokenRequest
     queue:[NSOperationQueue mainQueue]
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         NSString *clientToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         self.braintree = [Braintree braintreeWithClientToken:clientToken];
         NSLog(@"%@",clientToken);
     }];
    
    NSURL *url = [[NSURL alloc] initWithString:@"https://safe-springs-8517.herokuapp.com/"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data_, NSURLResponse *response, NSError *error) {
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:data_ options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"Data: %@",data);
        NSLog(@"Error: %@",error);
    }] resume];
    
    /*
    
    let request = NSMutableURLRequest(URL: NSURL(string:NSString(format: pathUrl,M3ServerAPI.sharedInstance.token!) as String)!)
    if(method == M3ServerMethodType.Post)
    {
        request.HTTPMethod = "POST"
        request.HTTPBody =  data?.dataUsingEncoding(NSUTF8StringEncoding)
    }
    let query = NSURLSession.sharedSession().dataTaskWithRequest(request)
    {data_, response, error in
        if error != nil
        {
            completion(responseData: nil,response: M3ServerResponse.NetworkError)
        }
        else{
            if data_ != nil
            {
                var jsonError: NSError?
                var  data  =  NSJSONSerialization.JSONObjectWithData(data_!, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as! NSDictionary
                if let error_ = data["error"] as? String
                {
                    if error_ == "wrong_token" {
                        completion(responseData:nil,response:M3ServerResponse.WrongTokenError)
                    }
                    else
                    {
                        completion(responseData:nil,response:M3ServerResponse.UnknownError)
                    }
                }
                else
                {
                    completion(responseData:data,response:M3ServerResponse.Success)
                }
            }
            else
            {
                completion(responseData:nil,response:M3ServerResponse.UnknownError)
            }
        }
    }
    query.resume()
    
    */
    
}



- (IBAction)tappedMyPayButton {
    BTDropInViewController *dropInViewController = [self.braintree dropInViewControllerWithDelegate:self];
    dropInViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:dropInViewController] animated:YES completion:nil];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dropInViewController:(__unused BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod {
    [self postNonceToServer:paymentMethod.nonce]; // Send payment method nonce to your server
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewControllerDidCancel:(__unused BTDropInViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)postNonceToServer:(NSString *)paymentMethodNonce {
    NSURL *paymentURL = [NSURL URLWithString:@"https://safe-springs-8517.herokuapp.com/payment-methods"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:paymentURL];
    request.HTTPBody = [[NSString stringWithFormat:@"payment_method_nonce=%@", paymentMethodNonce] dataUsingEncoding:NSUTF8StringEncoding];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               NSLog(@"Response: %@",response);
                               
                               NSLog(@"Data: %@",data);
                               
                               NSLog(@"Connection Error: %@",connectionError);
    }];
}

@end
