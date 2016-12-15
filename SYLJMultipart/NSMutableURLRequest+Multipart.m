
#import "NSMutableURLRequest+Multipart.h"

/** boundary 变量是保存在静态区，只有一个副本，字符串内容是保存在常量区的 */
static NSString *boundary = @"heimaupload";
/** userfile 是提交给服务器的脚本中的字段，可以咨询后台程序员，或者用 firebug 拦截 */
static NSString *serverField = @"userfile";

@implementation NSMutableURLRequest (Multipart)

/**
 目的：把常用的方法抽取出来，今后使用！
 
 步骤
 1. 新建一个方法
 2. 把要重构的代码复制过来
 3. 修改参数
 
 以下内容，是在 iOS 中，如果要上传文件，需要拼接的数据格式！
 
 \n--同上\n
 Content-Disposition: form-data; name="userfile"; filename="demo.html" \n
 Content-Type: text/html \n\n
 
 // 要上传文件的二进制数据
 
 \n\n--同上--\n
 
 提示：如果今后工作中，遇到不能用第三方框架上传的时候，记着这个分类！
 需要记住数据格式的获取，不同的服务器，要求的数据格式有可能会变化！利用 FireFox + firebug 拦截！
 
 尤其需要注意 \n 的数量！
 */
+ (instancetype)requestWithURL:(NSURL *)URL fileName:(NSString *)fileName localFilePath:(NSString *)localFilePath {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:0 timeoutInterval:20.0f];
    
    request.HTTPMethod = @"POST";
    
    // 生成请求体的二进制数据
    NSMutableData *data = [NSMutableData data];
    // 2.1. \n--同上\n
    NSString *bodyStr = [NSString stringWithFormat:@"\n--%@\n", boundary];
    [data appendData:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    // 2.2. Content-Disposition: form-data; name="userfile"; filename="demo.html" \n
    bodyStr = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\" \n", serverField, fileName];
    [data appendData:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    // 2.3 Content-Type: text/html \n\n
    bodyStr = @"Content-Type: application/stream\n\n";
    [data appendData:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 2.4 追加要上传文件的二进制数据
    [data appendData:[NSData dataWithContentsOfFile:localFilePath]];
    // 2.5 \n\n--同上--\n
    bodyStr = [NSString stringWithFormat:@"\n--%@--\n", boundary];
    [data appendData:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 设置 HTTP 的请求体
    request.HTTPBody = data;
    
    // 2.6 告诉服务器客户端要上传文件！要告诉服务器的附加信息，都是通过这个方法 forHTTPHeaderField
    NSString *headerString = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:headerString forHTTPHeaderField:@"Content-Type"];
    
    return request;
}

@end
