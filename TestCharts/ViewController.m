//
//  ViewController.m
//  TestCharts
//
//  Created by Summer on 2018/11/14.
//  Copyright © 2018 Summer. All rights reserved.
//

#import "ViewController.h"
#import <Charts/Charts-Swift.h>
#import <Masonry/Masonry.h>

#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1.0]


@interface ViewController ()<ChartViewDelegate>
@property (nonatomic , strong)  PieChartView *chartView;
@property (nonatomic , strong)  PieChartData *chartData;
@property (nonatomic , strong) NSArray *numbers;
@property (nonatomic , strong)  NSArray *names;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PieChartView *chartView = [[PieChartView alloc]init];
    [self.view addSubview:chartView];
    [chartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(chartView.superview.mas_centerY);
    make.left.equalTo(chartView.superview).offset(10);
        make.right.equalTo(chartView.superview).offset(-10);

        
        make.height.equalTo(chartView.mas_width);
    }];
    
    
    /* 基本样式 */
    chartView.delegate = self;//设置代理
    [chartView setExtraOffsetsWithLeft:5.f top:5.f right:5.f bottom:5.f];//饼状图距离边缘的间隙
    chartView.usePercentValuesEnabled = YES; //是否根据所提供的数据, 将显示数据转换为百分比格式
    chartView.dragDecelerationEnabled = YES;//拖拽饼状图后是否有惯性效果
    
    
    /* 设置饼状图中间的文本 */
    chartView.drawCenterTextEnabled = YES;//是否绘制中间的文本
//    chartView.centerText = @"我是中心";//中间文本的文字，默认为灰色,设置中间文本的字体、颜色属性没有找到，可以用centerAttributedText代替
    NSString *text = @"我是中心";
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:text];
    NSDictionary *dic = @{NSForegroundColorAttributeName : [UIColor cyanColor],NSFontAttributeName : [UIFont systemFontOfSize:20]};
    [attribute setAttributes:dic range:NSMakeRange(0, text.length)];
    chartView.centerAttributedText = attribute;
    
    
    /* 设置饼状图中间的同心圆 */
    chartView.drawHoleEnabled = YES; //饼状图是否是空心圆,设置为NO之后，半透明空心圆也消失咯
    chartView.holeRadiusPercent = 0.35;//第一个空心圆半径占比
    chartView.holeColor = [UIColor whiteColor];//第一个空心圆颜色
    chartView.transparentCircleRadiusPercent = 0.38;//第二个空心圆半径占比，半径占比和第一个空心圆半径占比设置为一样的时候，只有一个圆咯
    chartView.transparentCircleColor = UIColorFromHex(0xf1f1f1);//第二个空心圆颜色
    
    /* 设置饼状图图例样式 */
    chartView.legend.enabled = YES;//显示饼状图图例解释说明
    chartView.legend.maxSizePercent = 0.1;///图例在饼状图中的大小占比, 这会影响图例的宽高
    chartView.legend.formToTextSpace = 10;//图示和文字的间隔
    chartView.legend.font = [UIFont systemFontOfSize:10];//图例字体大小
    chartView.legend.textColor = [UIColor blackColor];//图例字体颜色
    chartView.legend.form = ChartLegendFormSquare;//图示样式: 方形、线条、圆形
    chartView.legend.formSize = 5;//图示大小
    
    /*饼状图交互*/
    chartView.rotationEnabled = YES;//是否可以选择旋转
    chartView.highlightPerTapEnabled = YES;//每个模块是否可点击
    
    /*饼状图没有数据的显示*/
    chartView.noDataText = @"暂无数据";//没有数据是显示的文字说明
    chartView.noDataTextColor = UIColorFromHex(0x21B7EF);//没有数据时的文字颜色
    chartView.noDataFont = [UIFont fontWithName:@"PingFangSC" size:15];//没有数据时的文字字体
    _chartView = chartView;
    
    _numbers = @[@"10",@"20",@"30",@"40"];
    _names = @[@"情况1",@"情况2",@"情况3",@"情况4"];
    
    //为饼状图提供数据
    _chartView.data = [self setDayData];
    
    /* 设置饼状图动画 */
    chartView.rotationAngle = 0.0;//动画开始时的角度在0度
    [chartView animateWithXAxisDuration:2.0f easingOption:ChartEasingOptionEaseOutExpo];//设置动画效果
    
//    [chartView highlightValueWithX:0 dataSetIndex:0 dataIndex:0 ];//默认选中第0e个数据
}

- (PieChartData *)setDayData{
    /*
     饼状图
     value : 每块扇形的数值
     label : 每块扇形的文字描述
     data  : tag值
     */
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for (int i = 0; i < _numbers.count; i++){
        [values addObject:[[PieChartDataEntry alloc] initWithValue:[_numbers[i] doubleValue] label:_names[i] data:[NSString stringWithFormat:@"%d",i]]];
    }
   
    /*
     图例
     value : 每行的文字描述
     label : 图例的名字
     */
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithValues:values label:@"图例说明"];//图例说明
    dataSet.entryLabelColor = [UIColor redColor];//修改每块扇形文字的颜色
    dataSet.drawValuesEnabled = YES;//是否显示每块扇形的数值
    dataSet.valueColors = @[[UIColor redColor],[UIColor cyanColor],[UIColor greenColor],[UIColor grayColor]];//修改每块扇形数值的颜色
    dataSet.drawIconsEnabled = NO; //是否显示图片
    dataSet.sliceSpace = 5; //相邻区块之间的间距
    dataSet.selectionShift = 8;//选中区块时, 放大的半径
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    [colors addObject:UIColorFromHex(0x7AAAD8)];
    [colors addObject:UIColorFromHex(0xFFB22C)];
    [colors addObject:UIColorFromHex(0x7ECBC3)];
    [colors addObject:UIColorFromHex(0xB1ACDA)];
    dataSet.colors = colors;//扇形的颜色
    
    
    NSNumberFormatter *pFormatter = [[NSNumberFormatter alloc] init];
    pFormatter.numberStyle = NSNumberFormatterPercentStyle;
    pFormatter.maximumFractionDigits = 1;
    pFormatter.multiplier = @1.f;
    pFormatter.percentSymbol = @" %";
    [dataSet setValueFormatter:[[ChartDefaultValueFormatter alloc] initWithFormatter:pFormatter]];
    [dataSet setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11.f]];
    PieChartData *data = [[PieChartData alloc] initWithDataSet:dataSet];
    return data;
}

#pragma mark -- ChartViewDelegate

- (void)chartTranslated:(ChartViewBase *)chartView dX:(CGFloat)dX dY:(CGFloat)dY{
    NSLog(@"chartTranslated");
}

- (void)chartScaled:(ChartViewBase *)chartView scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY{
    NSLog(@"chartScaled");
}

- (void)chartValueNothingSelected:(ChartViewBase *)chartView{
    NSLog(@"chartValueNothingSelected");
}

- (void)chartValueSelected:(ChartViewBase *)chartView entry:(ChartDataEntry *)entry highlight:(ChartHighlight *)highlight{
    NSLog(@"chartValueSelected");
    //当前选中饼状图的值
    NSLog(@"---chartValueSelected---value: x = %g,y = %g",entry.x,  entry.y);
    //当前选中饼状图的index
    NSLog(@"---chartValueSelected---value:第 %@ 个数据", entry.data);
}

@end
