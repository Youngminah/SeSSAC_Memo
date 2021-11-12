# Basic Memo 

### Iphone 8 
![Simulator Screen Recording - iPhone 8 - 2021-11-12 at 18 13 20](https://user-images.githubusercontent.com/42762236/141441831-509ade24-265b-4a45-9ea8-22f715410ba6.gif)

### Iphone 13 Pro Max
![Simulator Screen Recording - iPhone 13 Pro Max - 2021-11-12 at 17 59 57](https://user-images.githubusercontent.com/42762236/141440014-c27fd265-6594-41ff-a9db-11f68947a7c6.gif)

</br>
</br>

## 기술스택
- Storyboard
- Rxswift
- Realm
- 다크모드 대응 (기본 애플 다크모드  사용)

</br>
</br>

## TMI
#### Rxswift 관련
- Rxswift로 앱을 구성해본건 첨이라 MVVM을 사용하다가 로직이 엉망이 되었다 
- 거기다 시간도 부족하여 코드 정리는 한개도 못함..
- Noti를 delegate형식이 아닌 RxReactive방식으로 구현하려고 했으나 실패함
- 이를 위해서 SceneCoordinator가 필요해보인다
- searchBar부분에선 과제에서 controller를 이용하라고 되어있어서, Rx로 바인딩하진 않았다. (delegate 사용)
- leadingswipe부분도 rx문서를 찾아보니 delegate로 그냥 바인딩 하는듯 하다 
- (암튼 모든 tableview delegate 기능 대신 rx를 사용할 수 있는것은 아닌듯?)
- `장점`
  - rxswift로 구현하면 이벤트 발생을 할때마다 ui를 업데이트 해주어야 하는 부분이나 데이터 가공면에서 효과적 구현가능.
  - 예를들면, 서치바의 실시간 검색부분에서 Rxswift로 간단하게 구현 가능
- `단점`
  - Rxswift는 오류가 알수없는 곳에서 생기면 로직이 복잡하기 때문에 디버깅하여 오류를 잡기가 어렵다..!.. 
  - 그냥 느낀점인줄 알았는데 원래 단점이라더라ㅠ 

#### Realm 관련
- Realm을 쓰란 명시는 안되어 있었지만 개인 앱을 위해 써봄
- RxRealm을 쓰려고 했는데, 사실 RxRealm와 Rxswift를 어떻게 잘 구성해야 될지 모르겠음.
- 그리고 RxRealm을 쓰더라도 기본적 테이블 스키마모델 같은건 RealmSwift로 해야함.
- `장점`
  - 확실히 Realm을 쓰니까 동기화 때문에 코드로 CRUD를 구성하기는 쉬워진다
- `단점`
  - Realm에서 가져온 데이터들을 뷰에 보여줄 때 조금만 복잡하게 변형을 하면 
  - (예를 들면 이번과제에서, searchbar에서 실시간 검색에서 보여지는 테이블 뷰에서도 수정 삭제 고정이 가능했어야함)
  - 수정, 삭제를 할 때, Realm안에 데이터와 동기화 하기가 까다로움.. 
  - id나, date를 사용하는 방법으로 했는데,, 좀 더 생각해보아야 할 듯 


#### 느낀점
- 아키텍쳐의 필요성을 많이 느꼇다.
- Rxswift의 Operator는 자유롭게 사용하려면 많이 구현해보는 수 밖에 답이 없는 듯하다.
- Rxswift를 장점을 이용하여 MVVM을 구성해보아야 할 것 같다

