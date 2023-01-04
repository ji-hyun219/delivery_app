abstract class IModelWithId {
  final String id;

  IModelWithId({
    required this.id,
  });
}

// 이 모델을 implements 하면 그것들은 모두 이 id 값이 강제로 들어감