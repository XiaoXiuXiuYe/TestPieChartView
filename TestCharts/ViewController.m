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
@property (nonatomic , assign) BOOL isValueLine;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PieChartView *chartView = [[PieChartView alloc]init];
    [self.view addSubview:chartView];
    _chartView = chartView;
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
    
    /* 设置饼状图扇形区块文本*/
    chartView.drawEntryLabelsEnabled = YES; //是否显示扇形区块文本描述
    
    /*饼状图没有数据的显示*/
    chartView.noDataText = @"暂无数据";//没有数据是显示的文字说明
    chartView.noDataTextColor = UIColorFromHex(0x21B7EF);//没有数据时的文字颜色
    chartView.noDataFont = [UIFont fontWithName:@"PingFangSC" size:15];//没有数据时的文字字体
    
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
    chartView.highlightPerTapEnabled = YES;//每个扇形区块是否可点击

    
    /*  为饼状图提供数据 */
    _numbers = @[@"10",@"20",@"30",@"40"];
    _names = @[@"情况1",@"情况2",@"情况3",@"情况4"];
    [self setPieData];
//    [chartView highlightValueWithX:0 dataSetIndex:0 dataIndex:0 ];//默认选中第0个数据
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    [button setTitle:@"设置为带折线的饼状图" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(respondsToButton:) forControlEvents:UIControlEventTouchUpInside
     ];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(50);
        make.right.equalTo(self.view).offset(-20);
    }];
    
}

- (void)respondsToButton:(UIButton *)sender{
    sender.selected = !sender.selected;
    [sender setTitle:sender.selected == YES ? @"设置为不带折线的饼状图" :@"设置为带折线的饼状图" forState:UIControlStateNormal];
    self.isValueLine = sender.selected;
    [self setPieData];
}

- (void)setPieData{
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for (int i = 0; i < _numbers.count; i++){
        /*
         value : 每块扇形的数值
         label : 每块扇形的文字描述
         icon  : 图片
         */
        [values addObject:[[PieChartDataEntry alloc]initWithValue:[_numbers[i] doubleValue] label:_names[i] icon:nil]];
        
        /*
         value : 每块扇形的数值
         label : 每块扇形的文字描述
         data  : tag值
         */
        [values addObject:[[PieChartDataEntry alloc] initWithValue:[_numbers[i] doubleValue] label:_names[i] data:[NSString stringWithFormat:@"%d",i]]];
    }
   
    /*
     图例
     values : values数组
     label : 图例的名字
     */
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithValues:values label:@"图例说明"];//图例说明
    /* 设置每块扇形区块的颜色 */
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    [colors addObject:UIColorFromHex(0x7AAAD8)];
    [colors addObject:UIColorFromHex(0xFFB22C)];
    [colors addObject:UIColorFromHex(0x7ECBC3)];
    [colors addObject:UIColorFromHex(0xB1ACDA)];
    dataSet.colors = colors;
    
    dataSet.sliceSpace = 5; //相邻区块之间的间距
    dataSet.selectionShift = 8;//选中区块时, 放大的半径
    
    dataSet.drawIconsEnabled = NO; //扇形区块是否显示图片
    
    dataSet.entryLabelColor = [UIColor redColor];//每块扇形文字描述的颜色
    dataSet.entryLabelFont = [UIFont systemFontOfSize:15];//每块扇形的文字字体大小
    
    dataSet.drawValuesEnabled = YES;//是否显示每块扇形的数值
    dataSet.valueFont = [UIFont systemFontOfSize:11];//每块扇形数值的字体大小
    dataSet.valueColors = @[[UIColor redColor],[UIColor cyanColor],[UIColor greenColor],[UIColor grayColor]];//每块扇形数值的颜色,如果数值颜色要一样，就设置一个色就好了

    if (self.isValueLine) {
        /* 数值与区块之间的用于指示的折线样式*/
        dataSet.xValuePosition = PieChartValuePositionInsideSlice;//文字的位置
        dataSet.yValuePosition = PieChartValuePositionOutsideSlice;//数值的位置，只有在外面的时候，折线才有用
        dataSet.valueLinePart1OffsetPercentage = 0.8; //折线中第一段起始位置相对于区块的偏移量, 数值越大, 折线距离区块越远
        dataSet.valueLinePart1Length = 0.4;//折线中第一段长度占比
        dataSet.valueLinePart2Length = 0.6;//折线中第二段长度占比
        dataSet.valueLineWidth = 1;//折线的粗细
        dataSet.valueLineColor = [UIColor brownColor];//折线颜色
    }
    //设置每块扇形数值的格式
    NSNumberFormatter *pFormatter = [[NSNumberFormatter alloc] init];
    pFormatter.numberStyle = NSNumberFormatterPercentStyle;
    pFormatter.maximumFractionDigits = 1;
    pFormatter.multiplier = @1.f;
    pFormatter.percentSymbol = @" %";
    dataSet.valueFormatter = [[ChartDefaultValueFormatter alloc] initWithFormatter:pFormatter];
  
    PieChartData *data = [[PieChartData alloc] initWithDataSet:dataSet];
    self.chartView.data = data;
    
    /* 设置饼状图动画 */
    self.chartView.rotationAngle = 0.0;//动画开始时的角度在0度
    [self.chartView animateWithXAxisDuration:2.0f easingOption:ChartEasingOptionEaseOutExpo];//设置动画效果
    
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
