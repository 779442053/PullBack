<h2>一、分析</h2>
<blockquote>
<p>iOS7后系统新加了导航控制器侧滑返回功能</p>
</blockquote>
<p>1、肯定有一个手势来管理这个动作。</p>
<p>2、可以看到interactivePopGestureRecognizer属性 而且是readonly目测无法修改。用 kvo也没用</p>
<blockquote>
<p>UIScreenEdgePanGestureRecognizer</p>
</blockquote>
<p>3、手势对象里面肯定有许多事件回调（参考：）</p>
<blockquote>
<p>- (instancetype)initWithTarget:(nullable id)target action:(nullable SEL)action NS_DESIGNATED_INITIALIZER; // designated initializer</p>
</blockquote>
<p>4、使用runtime可以获取到interactivePopGestureRecognizer对象中有一个_targets的私有属性（数组，里面存放了一个私有类的对象）</p>
<blockquote>
<p>UIGestureRecognizerTarget</p>
</blockquote>
<p>5、使用断点调试可以发现对象里面 _target 属性 回调方法为： handleNavigationTransition:</p>
<blockquote>
<p>UINavigationInteractiveTransition</p>
</blockquote>
<p>6、使用KVO获取到这个属性和SEL 以后便可以自己操作了</p>
<p>7、自己创建一个UIPanGestureRecognizer对象交给 _target 和 target 来处理即可，同时把系统的手势禁止掉</p>
<p>代码实现：</p>
<p>&nbsp;</p>
<div class="cnblogs_code" onclick="cnblogs_code_show('99b7ae3b-c357-4744-8ffa-74c2ac38fffc')"><img id="code_img_closed_99b7ae3b-c357-4744-8ffa-74c2ac38fffc" class="code_img_closed" src="http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif" alt="" width="16" height="16" /><img id="code_img_opened_99b7ae3b-c357-4744-8ffa-74c2ac38fffc" class="code_img_opened" style="display: none;" onclick="cnblogs_code_hide('99b7ae3b-c357-4744-8ffa-74c2ac38fffc',event)" src="http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif" alt="" />
<div id="cnblogs_code_open_99b7ae3b-c357-4744-8ffa-74c2ac38fffc" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> <span style="color: #808080;">///</span><span style="color: #008000;"> false: 关闭 true: 打开</span>
<span style="color: #008080;"> 2</span> let kopenPullBack = <span style="color: #0000ff;">true</span>
<span style="color: #008080;"> 3</span> 
<span style="color: #008080;"> 4</span> <span style="color: #000000;">import UIKit
</span><span style="color: #008080;"> 5</span> 
<span style="color: #008080;"> 6</span> <span style="color: #000000;">extension UINavigationController {
</span><span style="color: #008080;"> 7</span>     
<span style="color: #008080;"> 8</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">override</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> func initialize() {
</span><span style="color: #008080;"> 9</span> 
<span style="color: #008080;">10</span>         <span style="color: #0000ff;">struct</span><span style="color: #000000;"> Static {
</span><span style="color: #008080;">11</span>             <span style="color: #0000ff;">static</span> var token: dispatch_once_t = <span style="color: #800080;">0</span>
<span style="color: #008080;">12</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">13</span>         dispatch_once(&amp;<span style="color: #000000;">Static.token) {
</span><span style="color: #008080;">14</span>             <span style="color: #0000ff;">if</span><span style="color: #000000;"> kopenPullBack {
</span><span style="color: #008080;">15</span>                 let m1 =<span style="color: #000000;"> class_getInstanceMethod(self, #selector(viewDidLoad))
</span><span style="color: #008080;">16</span>                 let m2 =<span style="color: #000000;"> class_getInstanceMethod(self, #selector(bm_viewDidLoad))
</span><span style="color: #008080;">17</span>                 
<span style="color: #008080;">18</span>                 let sel =<span style="color: #000000;"> class_addMethod(self, #selector(viewDidLoad), method_getImplementation(m2), method_getTypeEncoding(m2))
</span><span style="color: #008080;">19</span>                 <span style="color: #0000ff;">if</span><span style="color: #000000;"> sel {
</span><span style="color: #008080;">20</span> <span style="color: #000000;">                    class_replaceMethod(self, #selector(bm_viewDidLoad), method_getImplementation(m1), method_getTypeEncoding(m1))
</span><span style="color: #008080;">21</span>                 }<span style="color: #0000ff;">else</span><span style="color: #000000;">{
</span><span style="color: #008080;">22</span> <span style="color: #000000;">                    method_exchangeImplementations(m1, m2)
</span><span style="color: #008080;">23</span> <span style="color: #000000;">                }
</span><span style="color: #008080;">24</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">25</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">26</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">27</span> 
<span style="color: #008080;">28</span>     func bm_viewDidLoad() -&gt;<span style="color: #000000;"> () {
</span><span style="color: #008080;">29</span>         let tempGes =<span style="color: #000000;"> self.interactivePopGestureRecognizer
</span><span style="color: #008080;">30</span>         tempGes?.enabled = <span style="color: #0000ff;">false</span>
<span style="color: #008080;">31</span>         let _targets = tempGes?.valueForKey(<span style="color: #800000;">"</span><span style="color: #800000;">_targets</span><span style="color: #800000;">"</span><span style="color: #000000;">)
</span><span style="color: #008080;">32</span>         let _target = _targets?.firstObject!!.valueForKey(<span style="color: #800000;">"</span><span style="color: #800000;">target</span><span style="color: #800000;">"</span><span style="color: #000000;">)
</span><span style="color: #008080;">33</span>         let sel = NSSelectorFromString(<span style="color: #800000;">"</span><span style="color: #800000;">handleNavigationTransition:</span><span style="color: #800000;">"</span><span style="color: #000000;">)
</span><span style="color: #008080;">34</span>         let pan = UIPanGestureRecognizer.init(target: _target!<span style="color: #000000;">, action: sel)
</span><span style="color: #008080;">35</span>         tempGes!.view?<span style="color: #000000;">.addGestureRecognizer(pan)
</span><span style="color: #008080;">36</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">37</span> }</pre>
</div>
<span class="cnblogs_code_collapse">View Code</span></div>
<p>&nbsp;</p>
<h2>二、升级</h2>
<p>OC</p>
<div class="cnblogs_code">
<pre><span style="color: #0000ff;">#import</span> &lt;UIKit/UIKit.h&gt;
<span style="color: #0000ff;">#import</span> &lt;objc/runtime.h&gt;


<span style="color: #0000ff;">@implementation</span><span style="color: #000000;"> UINavigationController (BMBack)

</span>+ (<span style="color: #0000ff;">void</span><span style="color: #000000;">)load {
    </span><span style="color: #0000ff;">if</span> (!kopenPullBack) <span style="color: #0000ff;">return</span><span style="color: #000000;">;

    </span><span style="color: #0000ff;">static</span><span style="color: #000000;"> dispatch_once_t onceToken;
    dispatch_once(</span>&amp;onceToken, ^<span style="color: #000000;">{
        
        Method m1 </span>= class_getInstanceMethod([self <span style="color: #0000ff;">class</span><span style="color: #000000;">], @selector(viewDidLoad));
        Method m2 </span>= class_getInstanceMethod([self <span style="color: #0000ff;">class</span><span style="color: #000000;">], @selector(bm_viewDidLoad));
        
        </span><span style="color: #008000;">/*</span><span style="color: #008000;">!
        分析 </span><span style="color: #008000; text-decoration: underline;">http://blog.leichunfeng.com/blog/2015/06/14/objective-c-method-swizzling-best-practice/</span>
         <span style="color: #008000;">*/</span><span style="color: #000000;">
        BOOL sel </span>=<span style="color: #000000;"> class_addMethod(self, @selector(viewDidLoad), method_getImplementation(m2), method_getTypeEncoding(m2));
        </span><span style="color: #0000ff;">if</span> (!<span style="color: #000000;">sel) {
            </span><span style="color: #008000;">//</span><span style="color: #008000;"> 添加失败 说明本类已经实现了方法 交换即可</span>
<span style="color: #000000;">            method_exchangeImplementations(m1, m2);
        }</span><span style="color: #0000ff;">else</span><span style="color: #000000;">{
            </span><span style="color: #008000;">//</span><span style="color: #008000;"> 添加成功 说明本类没有实现此方法可能由父类实现 就替换掉方法</span>
<span style="color: #000000;">            class_replaceMethod(self, @selector(bm_viewDidLoad), method_getImplementation(m1), method_getTypeEncoding(m2));
        }
    });
}

</span>- (<span style="color: #0000ff;">void</span><span style="color: #000000;">)bm_viewDidLoad {
    [self bm_viewDidLoad];
    </span><span style="color: #008000;">//</span><span style="color: #008000;"> 获取手势</span>
    UIGestureRecognizer *tempGes =<span style="color: #000000;"> self.interactivePopGestureRecognizer;
    </span><span style="color: #008000;">//</span><span style="color: #008000;"> 关闭此手势</span>
    tempGes.enabled =<span style="color: #000000;"> NO;
    </span><span style="color: #008000;">//</span><span style="color: #008000;"> 获取手势的回调数组</span>
    NSMutableArray *_targets = [tempGes valueForKey:<span style="color: #800000;">@"</span><span style="color: #800000;">_targets</span><span style="color: #800000;">"</span><span style="color: #000000;">];

    </span><span style="color: #008000;">//</span><span style="color: #008000;"> 获取系统的侧滑手势的回调对象和方法</span>
    <span style="color: #0000ff;">id</span> tar = [[_targets firstObject] valueForKey:<span style="color: #800000;">@"</span><span style="color: #800000;">target</span><span style="color: #800000;">"</span><span style="color: #000000;">];

    SEL sel </span>= NSSelectorFromString(<span style="color: #800000;">@"</span><span style="color: #800000;">handleNavigationTransition:</span><span style="color: #800000;">"</span><span style="color: #000000;">);
    </span><span style="color: #008000;">//</span><span style="color: #008000;"> 创建一个手势 添加上去</span>
    UIPanGestureRecognizer *pan =<span style="color: #000000;"> [[UIPanGestureRecognizer alloc] initWithTarget:tar action:sel];
    [tempGes.view addGestureRecognizer:pan];
}</span></pre>
</div>
<p>swift</p>
<div class="cnblogs_code">
<pre><span style="color: #808080;">///</span><span style="color: #008000;"> false: 关闭 true: 打开</span>
let kopenPullBack = <span style="color: #0000ff;">true</span><span style="color: #000000;">

import UIKit

extension UINavigationController {
    
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">override</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> func initialize() {

        </span><span style="color: #0000ff;">struct</span><span style="color: #000000;"> Static {
            </span><span style="color: #0000ff;">static</span> var token: dispatch_once_t = <span style="color: #800080;">0</span><span style="color: #000000;">
        }
        dispatch_once(</span>&amp;<span style="color: #000000;">Static.token) {
            </span><span style="color: #0000ff;">if</span><span style="color: #000000;"> kopenPullBack {
                let m1 </span>=<span style="color: #000000;"> class_getInstanceMethod(self, #selector(viewDidLoad))
                let m2 </span>=<span style="color: #000000;"> class_getInstanceMethod(self, #selector(bm_viewDidLoad))
                
                let sel </span>=<span style="color: #000000;"> class_addMethod(self, #selector(viewDidLoad), method_getImplementation(m2), method_getTypeEncoding(m2))
                </span><span style="color: #0000ff;">if</span><span style="color: #000000;"> sel {
                    class_replaceMethod(self, #selector(bm_viewDidLoad), method_getImplementation(m1), method_getTypeEncoding(m1))
                }</span><span style="color: #0000ff;">else</span><span style="color: #000000;">{
                    method_exchangeImplementations(m1, m2)
                }
            }
        }
    }

    func bm_viewDidLoad() </span>-&gt;<span style="color: #000000;"> () {
        let tempGes </span>=<span style="color: #000000;"> self.interactivePopGestureRecognizer
        tempGes</span>?.enabled = <span style="color: #0000ff;">false</span><span style="color: #000000;">
        let _targets </span>= tempGes?.valueForKey(<span style="color: #800000;">"</span><span style="color: #800000;">_targets</span><span style="color: #800000;">"</span><span style="color: #000000;">)
        let _target </span>= _targets?.firstObject!!.valueForKey(<span style="color: #800000;">"</span><span style="color: #800000;">target</span><span style="color: #800000;">"</span><span style="color: #000000;">)
        let sel </span>= NSSelectorFromString(<span style="color: #800000;">"</span><span style="color: #800000;">handleNavigationTransition:</span><span style="color: #800000;">"</span><span style="color: #000000;">)
        let pan </span>= UIPanGestureRecognizer.init(target: _target!<span style="color: #000000;">, action: sel)
        tempGes</span>!.view?<span style="color: #000000;">.addGestureRecognizer(pan)
    }
}</span></pre>
</div>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
