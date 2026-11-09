/// The "How I Build" content: how AI agents are directed across delivery.
class WorkflowOverview {
  final String intro;
  final List<WorkflowStage> stages;

  /// Public evidence of the workflow, shown as a link.
  final String proofUrl;

  const WorkflowOverview({
    required this.intro,
    required this.stages,
    required this.proofUrl,
  });
}

class WorkflowStage {
  final String title;
  final String agentWork;
  final String ownership;

  const WorkflowStage({
    required this.title,
    required this.agentWork,
    required this.ownership,
  });
}
