import 'package:flutter/material.dart';
import 'package:efox_flutter/store/STORE.dart' show STORE;
import 'package:efox_flutter/components/markdownComp.dart' as MarkDownComp;
import 'package:efox_flutter/lang/app_translations.dart' show AppTranslations;
import 'package:efox_flutter/components/baseComp.dart' as BaseComp;
import 'package:efox_flutter/components/exampleComp.dart' as ExampleComp;
import 'package:efox_flutter/utils/file.dart' as FileUtils;
import 'package:efox_flutter/router/index.dart' show FluroRouter;

class Index extends StatefulWidget {
  final List<Widget> demoChild;
  final String originCodeUrl;
  final String codeUrl;
  final String mdUrl;
  final String name;
  Index({
    Key key,
    this.name,
    this.demoChild,
    this.originCodeUrl,
    this.codeUrl,
    this.mdUrl,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => IndexState(
      name: name,
      demoChild: demoChild,
      originCodeUrl: originCodeUrl,
      codeUrl: codeUrl,
      mdUrl: mdUrl);
}

class IndexState extends State<Index> {
  List<Widget> _bodyList = [];
  final dynamic modelChild;
  final List mdList;
  final List<Widget> demoChild;
  final String originCodeUrl;
  final String codeUrl;
  final String mdUrl;
  final String name;
  bool loading = true;
  dynamic model;

  IndexState({
    Key key,
    this.name,
    this.modelChild,
    this.mdList,
    this.demoChild,
    this.originCodeUrl,
    this.codeUrl,
    this.mdUrl,
  });

  @override
  void initState() {
    super.initState();
    this.init();
  }

  void init() async {
    this._bodyList.length = 0;
    this._bodyList.add(await MarkDownComp.Index(await this.getMdFile(this.mdUrl)));

    // 增加
    if (this.demoChild != null) {
      this.demoChild.forEach((Widget item) {
        this._bodyList.add(ExampleComp.Index(child: item));
      });
    }
    
    print('end $_bodyList');
    setState(() {
      this.loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return STORE.connect(builder: (context, child, model) {
      this.model = model;
      return Scaffold(
        appBar: AppBar(
          title: Text(this.name),
          actions: this.getActions(context, model),
        ),
        body: this.loading ? this.renderLoading() : this.renderWidget(),
      );
    });
  }

  openPage(context, model, String url) async {
    // 加载页面
    if (model.configInfo.isPro) {
      FluroRouter.router.navigateTo(context,
          '/webview?url=${Uri.encodeComponent(this.model.configInfo.config['GitHubAssetOrigin'] + url)}');
    } else {
      // 加载本地
      String mdStr = await FileUtils.readLocaleFile(url);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) {
          return BaseComp.Index(
            title: this.name,
            child: (context, child, model) {
              return MarkDownComp.Index(mdStr);
            },
          );
        }),
      );
    }
  }

  Future getMdFile(url) async {
    String mdStr = await FileUtils.readLocaleFile(url);
    return mdStr;
  }

  getActions(context, model) {
    return [
      IconButton(
        icon: Icon(
          Icons.favorite_border,
        ),
        onPressed: () async {
          // TODO favirote
          this.openPage(context, model, this.mdUrl);
        },
      ),
      IconButton(
        icon: Icon(
          Icons.code,
        ),
        onPressed: () async {
          this.openPage(context, model, this.codeUrl);
        },
      ),
      PopupMenuButton(
        offset: Offset(0, 80),
        onSelected: (index) {
          switch (index) {
            case 0:
              FluroRouter.router.navigateTo(
                context,
                '/webview?url=${Uri.encodeComponent('https://github.com/efoxTeam/flutter-ui')}',
              );
              break;
            case 1:
              this.openPage(context, model, this.mdUrl);
              break;
            case 2:
              FluroRouter.router.navigateTo(
                context,
                '/webview?url=${Uri.encodeComponent(this.originCodeUrl)}',
              );
              break;
          }
        },
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              child: Row(children: [
                Icon(
                  Icons.home,
                ),
                Text('官网'),
              ]),
              value: 0,
            ),
            PopupMenuItem(
              child: Row(children: [
                Icon(
                  Icons.all_inclusive,
                ),
                Text("Markdown"),
              ]),
              value: 1,
            ),
            PopupMenuItem(
              child: Row(children: [
                Icon(
                  Icons.code,
                ),
                Text(this.name),
              ]),
              value: 2,
            ),
          ];
        },
      ),
    ];
  }

  Widget renderLoading() {
    return Center(
      child: Stack(
        children: <Widget>[
          // 遮罩
          Opacity(
            opacity: .8,
            child: ModalBarrier(
              color: Colors.black87,
            ),
          ),
          // 居中显示
          Center(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircularProgressIndicator(
                    backgroundColor: Color(this.model.theme.secondColor),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                    child: Text(
                      AppTranslations.of(context).t('loading'),
                      style: TextStyle(
                          color: Color(this.model.theme.secondColor),
                          fontSize: 16.0),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget renderWidget() {
    // 加载完成后返回页面
    return Scrollbar(
      child: ListView(
        padding: EdgeInsets.all(10.0),
        children: this._bodyList,
      ),
    );
  }
}