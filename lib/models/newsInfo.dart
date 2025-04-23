class NewsInfo {
  final int id;
  final int zhiboId;
  final String richText;
  final String creator;
  final String createTime;
  final String updateTime;
  final String anchorImageUrl;
  final String docurl;


  NewsInfo({
    required this.id,
    required this.zhiboId,
    required this.richText,
    required this.creator,
    required this.createTime,
    required this.updateTime,
    required this.anchorImageUrl,
    required this.docurl,
  });

  factory NewsInfo.fromJson(Map<String, dynamic> json) {
    return NewsInfo(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      zhiboId: int.tryParse(json['zhibo_id']?.toString() ?? '0') ?? 0,
      richText: json['rich_text'] ?? '',
      creator: json['creator'] ?? '',
      createTime: json['create_time'] ?? '',
      updateTime: json['update_time'] ?? '',
      anchorImageUrl: json['anchor_image_url'] ?? '',
      docurl: json['docurl'] ?? '',
    );
  }

/*
      "id": 4155848,
      "zhibo_id": 152,
      "type": 0,
      "rich_text": "【境外机构持续加码中国债市】中国人民银行数据显示，截至4月15日，共有1160余家境外机构进入中国债券市场，境外机构在我国持有债券总量为4.5万亿元，较2024年末增加2700多亿元。我国债券市场总规模已达到183万亿元，居世界第二位。“境外机构对中国债券市场的参与热情持续升温。”中信证券首席经济学家明明表示，这主要受以下因素驱动，一方面是中国宏观经济运行稳健，人民币债券价格波动小、回报稳定，具备分散化投资价值；另一方面，在美元指数波动、国际地缘政治风险上升的背景下，中国债市的避险属性逐渐增强，且中国债券在三大国际债券指数（彭博、摩根大通、富时罗素）中的权重稳步提升，吸引跟踪指数的被动资金流入。（证券日报）",
      "multimedia": "",
      "commentid": "live:finance-152-4155848:0",
      "compere_id": 0,
      "creator": "xuning5@staff.sina.com",
      "mender": "xuning5@staff.sina.com",
      "create_time": "2025-04-21 07:19:14",
      "update_time": "2025-04-21 07:19:22",
      "is_need_check": "0",
      "check_time": "1970-01-01 08:00:01",
      "check_status": "1",
      "check_user": "",
      "is_delete": 0,
      "top_value": 0,
      "is_focus": 0,
      "source_content_id": "0",
      "anchor_image_url": "",
      "anchor": "直播员",
      "ext":"{\"stocks\":[{\"market\":\"CFF\",\"symbol\":\"nf_tf0\",\"key\":\"\国\债\"},{\"market\":\"CFF\",\"symbol\":\"nf_t0\",\"key\":\"\国\债\"},{\"market\":\"CFF\",\"symbol\":\"nf_ts0\",\"key\":\"\国\债\"},{\"market\":\"fund\",\"symbol\":\"515290\",\"key\":\"\银\行\",\"sym_party_status\":\"0\"},{\"market\":\"cn\",\"symbol\":\"sh600030\",\"key\":\"\中\信\证\券\"},{\"market\":\"hk\",\"symbol\":\"06030\",\"key\":\"\中\信\证\券\"},{\"market\":\"us\",\"symbol\":\"ciihy\",\"key\":\"\中\信\证\券\"},{\"market\":\"foreign\",\"symbol\":\"DINIW\",\"key\":\"\美\元\指\数\"},{\"market\":\"fund\",\"symbol\":\"002611\",\"key\":\"\避\险\",\"sym_party_status\":\"0\"},{\"market\":\"us\",\"symbol\":\"jpm\",\"key\":\"\摩\根\大\通\"}],\"needPushWB\":false,\"needCMSLink\":true,\"needCalender\":false,\"docurl\":\"https:\\/\\/finance.sina.com.cn\\/7x24\\/2025-04-21\\/doc-inetwqye5363994.shtml\",\"docid\":\"netwqye5363994\"}",
      "old_live_cid": "0",
      "tab": "",
      "is_repeat": "0",
      "tag": [
          {
              "id": "5",
              "name": "市场"
          },
          {
              "id": "6",
              "name": "观点"
          }
      ],
      "like_nums": 0,
      "comment_list": {
          "list": [],
          "total": 0,
          "thread_show": 0,
          "qreply": 0,
          "qreply_show": 0,
          "show": 0
      },
      "docurl": "https://finance.sina.cn/7x24/2025-04-21/detail-inetwqye5363994.d.html",
      "rich_text_nick_to_url": [],
      "rich_text_nick_to_routeUri": [],
      "compere_info": ""
*/

} 