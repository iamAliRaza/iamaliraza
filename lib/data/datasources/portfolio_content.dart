import '../../domain/entities/certification_entry.dart';
import '../../domain/entities/education_entry.dart';
import '../../domain/entities/experience_entry.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/skill.dart';
import '../../domain/entities/social_link.dart';
import '../../domain/entities/workflow_overview.dart';

/// The portfolio's real content, sourced from Ali Raza's CV, as compile-time
/// const domain entities. This is the one file to edit when content changes;
/// no widget code should need to change. It's read only through
/// `PortfolioRepositoryImpl` — widgets never import this file directly.

const Profile portfolioProfile = Profile(
  name: 'Ali Raza',
  roleTitle: 'Mr.',
  headline: 'Mobile Product Engineer',
  heroBio:
      'I own mobile products end to end, directing AI agents across '
      'development, testing, release and automation, backed by nine years in '
      'native Android and Flutter. Currently building PerfeXe, an AI-powered '
      'agentic workspace platform, at eXceeders.',
  aboutBio:
      'My work centres on architecture that lasts: rebuilding legacy '
      'codebases on Clean Architecture, shipping one codebase as many '
      'white-labelled products, and moving teams onto Flutter without losing '
      "production quality. I've led cross-platform mobile teams, and I also "
      'built an AI-assisted engineering workflow with Claude Code and MCP, '
      'including Figma-to-code automation, to speed up delivery while keeping '
      'the architectural bar high.',
  email: 'hello@iamaliraza.com',
  profileImageAsset: 'assets/images/profile/profile_photo.jpg',
);

const List<SocialLink> portfolioSocialLinks = [
  SocialLink(
    platform: SocialPlatform.github,
    url: 'https://github.com/iamAliRaza',
    iconAssetPath: 'assets/icons/social/github.svg',
  ),
  SocialLink(
    platform: SocialPlatform.linkedIn,
    url: 'https://linkedin.com/in/aliraza--',
    iconAssetPath: 'assets/icons/social/linkedin.svg',
  ),
  // Facebook, Instagram and X return here once Ali has real profile URLs.
];

const List<SkillGroup> portfolioSkillGroups = [
  SkillGroup(
    title: 'AI & Agentic Engineering',
    display: SkillGroupDisplay.spotlight,
    skills: [
      Skill(
        name: 'Claude Code',
        iconAssetPath: 'assets/icons/skills/claude.svg',
      ),
      Skill(
        name: 'OpenAI Codex',
        iconAssetPath: 'assets/icons/skills/openai.svg',
      ),
      Skill(name: 'Cursor', iconAssetPath: 'assets/icons/skills/cursor.svg'),
      Skill(name: 'Google Antigravity'),
      Skill(name: 'MCP', iconAssetPath: 'assets/icons/skills/mcp.svg'),
      Skill(
        name: 'Figma to Code',
        iconAssetPath: 'assets/icons/skills/figma.svg',
      ),
    ],
  ),
  SkillGroup(
    title: 'Mobile',
    display: SkillGroupDisplay.tiles,
    skills: [
      Skill(name: 'Kotlin', iconAssetPath: 'assets/icons/skills/kotlin.svg'),
      Skill(name: 'Java', iconAssetPath: 'assets/icons/skills/java.svg'),
      Skill(
        name: 'Jetpack Compose',
        iconAssetPath: 'assets/icons/skills/jetpack_compose.svg',
      ),
      Skill(
        name: 'Android SDK',
        iconAssetPath: 'assets/icons/skills/android.svg',
      ),
      Skill(name: 'Flutter', iconAssetPath: 'assets/icons/skills/flutter.svg'),
      Skill(name: 'Dart', iconAssetPath: 'assets/icons/skills/dart.svg'),
      Skill(
        name: 'Riverpod',
        iconAssetPath: 'assets/icons/skills/riverpod.svg',
      ),
      Skill(name: 'Jaspr', iconAssetPath: 'assets/icons/skills/jaspr.png'),
    ],
  ),
  SkillGroup(
    title: 'Architecture',
    display: SkillGroupDisplay.list,
    skills: [
      Skill(name: 'Clean Architecture'),
      Skill(name: 'MVVM'),
      Skill(name: 'SOLID'),
      Skill(name: 'Dependency Injection'),
      Skill(name: 'Modular Design'),
    ],
  ),
  SkillGroup(
    title: 'Enterprise SaaS',
    display: SkillGroupDisplay.list,
    skills: [
      Skill(name: 'Multi-tenancy'),
      Skill(name: 'Role-based Access'),
      Skill(name: 'Dynamic Branding'),
      Skill(name: 'OAuth 2.0/OIDC'),
      Skill(name: 'Offline-first'),
    ],
  ),
  SkillGroup(
    title: 'Backend & Integration',
    display: SkillGroupDisplay.list,
    skills: [
      Skill(name: 'REST APIs'),
      Skill(name: 'Firebase'),
      Skill(name: 'Socket.io'),
      Skill(name: 'XMPP'),
      Skill(name: 'Stripe'),
      Skill(name: 'AppsFlyer'),
      Skill(name: 'SQL'),
    ],
  ),
  SkillGroup(
    title: 'Testing & Release',
    display: SkillGroupDisplay.list,
    skills: [
      Skill(name: 'JUnit'),
      Skill(name: 'CI/CD'),
      Skill(name: 'Fastlane'),
      Skill(name: 'Codemagic'),
      Skill(name: 'Crashlytics'),
      Skill(name: 'Google Play'),
      Skill(name: 'App Store'),
      Skill(name: 'Git'),
    ],
  ),
];

const WorkflowOverview portfolioWorkflow = WorkflowOverview(
  intro:
      'Nine years of mobile judgement, directing AI agents across the whole '
      'delivery cycle. The agents do the work. I own the decisions.',
  stages: [
    WorkflowStage(
      title: 'Plan',
      agentWork:
          'Turn a requirement or ticket into a technical plan and task '
          'breakdown',
      ownership: 'Scope and architecture decisions',
    ),
    WorkflowStage(
      title: 'Design to code',
      agentWork:
          'Read Figma through MCP and build screens from existing design '
          'tokens and components',
      ownership: 'UI fidelity and UX details',
    ),
    WorkflowStage(
      title: 'Build',
      agentWork:
          'Work in parallel, one per feature, in isolated Git worktrees, '
          'following project rules and integrating backend APIs',
      ownership: 'Reviewing every change before it merges',
    ),
    WorkflowStage(
      title: 'Test',
      agentWork:
          'Write unit, widget and integration tests, then fix what fails',
      ownership: 'The quality bar and critical user journeys',
    ),
    WorkflowStage(
      title: 'Release',
      agentWork:
          'Bump versions, write changelogs, build signed apps for each client '
          'flavor and upload to TestFlight and Google Play testing tracks with '
          'Fastlane and Codemagic',
      ownership: 'Approving every production rollout',
    ),
    WorkflowStage(
      title: 'Automate',
      agentWork:
          'Triage Crashlytics crash reports on a schedule, open fix PRs and '
          'keep dependencies current',
      ownership: 'Deciding what ships',
    ),
  ],
  proofUrl: 'https://github.com/iamAliRaza/iamaliraza/blob/main/CLAUDE.md',
);

// Newest first, one entry per company.
const List<ExperienceEntry> portfolioExperience = [
  ExperienceEntry(
    company: 'eXceeders',
    location: 'UAE · Remote',
    roles: [
      ExperienceRole(
        title: 'Senior Mobile Engineer — Flutter & Native Android',
        period: 'Feb 2026 – Present',
        highlights: [
          'Own Android and iOS delivery for PerfeXe as the sole mobile '
              'engineer on a 7-person cross-functional team',
          'Direct AI agents across planning, build, testing and release for '
              'PerfeXe, with human review on every change and production rollout',
          'Reduced design-handoff-to-working-UI time with an MCP-based '
              'Figma-to-code pipeline',
        ],
      ),
    ],
  ),
  ExperienceEntry(
    company: 'EXCEED IT Services',
    location: 'Abu Dhabi, UAE · Hybrid',
    roles: [
      ExperienceRole(
        title: 'Cross-Platform Engineer — Flutter & Native Android',
        period: 'Sep 2023 – Jan 2026',
        highlights: [
          'Piloted the native-to-Flutter transition with StemeXe Lite, '
              'validating the approach before it became the foundation for '
              'PerfeXe',
        ],
      ),
      ExperienceRole(
        title: 'Senior Android Engineer',
        period: 'Aug 2021 – Aug 2023',
        highlights: [
          'Led a 3-person Android team and rebuilt the legacy StemeXe '
              'codebase around MVVM and Clean Architecture',
          'Enabled 5–7 white-labelled production apps from a single codebase '
              'with flavor-based builds, across insurance, government, real '
              'estate and fintech',
        ],
      ),
    ],
  ),
  ExperienceEntry(
    company: 'Pakrism',
    location: 'Pakistan · Part-time',
    roles: [
      ExperienceRole(
        title: 'Lead Android Developer',
        period: 'Dec 2020 – Jul 2021',
        highlights: [
          'Built the native Android app end to end on Clean Architecture and '
              'MVVM, reaching 10,000+ downloads shortly after launch',
          'Led a 3-person cross-platform mobile team and integrated '
              'XMPP/Socket.io for real-time social features',
          'Mentored and trained the in-house developers, then handed the app '
              'over for them to continue',
        ],
      ),
    ],
  ),
  ExperienceEntry(
    company: 'Uni.Buzz',
    location: 'Dubai, UAE',
    roles: [
      ExperienceRole(
        title: 'Lead Android Developer',
        period: 'Nov 2020 – Mar 2021',
        highlights: [
          'Led and mentored a team of mobile developers while owning Android '
              'for a university social network',
          'Led code reviews and owned Android architecture decisions, sprint '
              'planning and delivery',
        ],
      ),
      ExperienceRole(
        title: 'Senior Android Developer',
        period: 'Jul 2019 – Oct 2020',
        highlights: [
          'Implemented real-time text and audio messaging using '
              'XMPP/Socket.io',
          'Maintained the production Android app across multiple languages '
              'and devices',
        ],
      ),
    ],
  ),
  ExperienceEntry(
    company: 'SunzTech',
    location: 'Pakistan',
    roles: [
      ExperienceRole(
        title: 'Senior Android Developer',
        period: 'Apr 2017 – Jun 2019',
        highlights: [
          'Built and maintained native Android apps end to end, translating '
              'product designs into production Java',
          'Modernised legacy applications and managed Google Play publishing '
              'and update cycles end to end',
          'Maintained quality through unit testing, debugging and production '
              'troubleshooting',
        ],
      ),
    ],
  ),
];

const List<EducationEntry> portfolioEducation = [
  EducationEntry(
    title: 'Bachelor of Science in Software Engineering (BSSE)',
    subtitle: 'Riphah International University, Pakistan',
  ),
];

const List<CertificationEntry> portfolioCertifications = [
  CertificationEntry(
    title: "Winner, Speed Programming Competition (SPC '16)",
    issuer: 'Riphah International University',
  ),
];

const List<Project> portfolioProjects = [
  Project(
    title: 'PerfeXe',
    category: ProjectCategory.featured,
    label: 'B2B Enterprise Platform · eXceeders',
    summary:
        'An AI-powered digital workplace that businesses roll out to their '
        'employees under their own brand, bringing tasks, attendance, '
        'approvals and Agentic AI into one app.',
    tech: ['Flutter', 'Dart', 'Android', 'iOS'],
    showcase: ProjectShowcase(
      coverAssetPath: 'assets/images/projects/perfexe_cover.jpg',
      proofLine: 'AI-powered B2B platform',
      highlights: [
        'Sole mobile engineer on a 7-person product team, owning both '
            'Android and iOS',
        'Built on the Flutter foundation I proved out with the StemeXe Lite '
            'pilot',
        'Introduced an MCP-based Figma-to-code pipeline that shortened the '
            'path from design handoff to working UI',
      ],
      screenshotAssetPaths: [
        'assets/images/projects/perfexe_01.jpg',
        'assets/images/projects/perfexe_02.jpg',
        'assets/images/projects/perfexe_03.jpg',
        'assets/images/projects/perfexe_04.jpg',
        'assets/images/projects/perfexe_05.jpg',
      ],
      storeLinks: [
        StoreLink(
          platform: StorePlatform.googlePlay,
          url: 'https://play.google.com/store/apps/details?id=com.perfexe.app',
          qrAssetPath: 'assets/images/projects/perfexe_play_qr.svg',
        ),
      ],
      isDemoListing: true,
      availabilityNote: 'iOS version currently in App Store review',
    ),
  ),
  Project(
    title: 'StemeXe',
    category: ProjectCategory.featured,
    label: 'B2B Enterprise Platform · White-labelled · eXceeders',
    summary:
        'A customisable digital workplace app on Android and iOS, delivered '
        'to client organisations as their own branded product.',
    tech: ['Android', 'iOS', 'MVVM', 'Clean Architecture', 'Flutter'],
    showcase: ProjectShowcase(
      coverAssetPath: 'assets/images/projects/stemexe_cover.jpg',
      proofLine: '5–7 white-labelled apps',
      highlights: [
        'Led a 3-person Android team and rebuilt a legacy codebase around '
            'MVVM and Clean Architecture',
        'Enabled 5–7 white-labelled production apps from a single codebase, '
            'across insurance, government, real estate and fintech',
        "Piloted the company's move to Flutter with StemeXe Lite, which "
            'became the foundation for PerfeXe',
      ],
      screenshotAssetPaths: [
        'assets/images/projects/stemexe_01.jpg',
        'assets/images/projects/stemexe_02.jpg',
        'assets/images/projects/stemexe_03.jpg',
        'assets/images/projects/stemexe_04.jpg',
        'assets/images/projects/stemexe_05.jpg',
        'assets/images/projects/stemexe_06.jpg',
      ],
      storeLinks: [
        StoreLink(
          platform: StorePlatform.googlePlay,
          url:
              'https://play.google.com/store/apps/details?id=com.exceeders.stemexe',
          qrAssetPath: 'assets/images/projects/stemexe_play_qr.svg',
        ),
        StoreLink(
          platform: StorePlatform.appStore,
          url: 'https://apps.apple.com/us/app/stemexe-app/id1502529266',
          qrAssetPath: 'assets/images/projects/stemexe_ios_qr.svg',
        ),
      ],
      isDemoListing: true,
    ),
  ),
  Project(
    title: 'Pakrism',
    category: ProjectCategory.featured,
    label: 'Consumer App · Contract',
    summary:
        'A travel discovery, tour booking and community app for Pakistan, '
        'taken from native Android to Flutter end to end and live on Android '
        'and iOS.',
    tech: ['Flutter', 'Dart', 'Android', 'iOS', 'AppsFlyer', 'Stripe'],
    showcase: ProjectShowcase(
      coverAssetPath: 'assets/images/projects/pakrism_cover.jpg',
      proofLine: '50K+ downloads · 4.8★ on Google Play',
      highlights: [
        'Originally built the native Android app, trained the in-house team '
            'and handed it over',
        'Returned to migrate the now 50K+ download app to Flutter end to end',
        'Added new feature modules during the migration',
        'Replaced Firebase Dynamic Links with AppsFlyer and integrated '
            'Stripe payments',
      ],
      screenshotAssetPaths: [
        'assets/images/projects/pakrism_01.jpg',
        'assets/images/projects/pakrism_02.jpg',
        'assets/images/projects/pakrism_03.jpg',
        'assets/images/projects/pakrism_04.jpg',
        'assets/images/projects/pakrism_05.jpg',
        'assets/images/projects/pakrism_06.jpg',
      ],
      storeLinks: [
        StoreLink(
          platform: StorePlatform.googlePlay,
          url: 'https://play.google.com/store/apps/details?id=com.pakrism',
          qrAssetPath: 'assets/images/projects/pakrism_play_qr.svg',
        ),
        StoreLink(
          platform: StorePlatform.appStore,
          url: 'https://apps.apple.com/us/app/pakrism/id1496630730',
          qrAssetPath: 'assets/images/projects/pakrism_ios_qr.svg',
        ),
      ],
    ),
  ),
  // No live listing or images, so no showcase. Newest first.
  Project(
    title: 'Uni.Buzz',
    category: ProjectCategory.earlier,
    label: 'Lead Android Developer',
    summary:
        'Educational social network for university students and professors. '
        'Native Android app with direct messaging, audio and file sharing, '
        'virtual classrooms, groups and a social feed.',
    tech: ['Android', 'XMPP', 'Socket.io'],
  ),
  Project(
    title: 'File Manager Ultimate',
    category: ProjectCategory.earlier,
    label: 'Freelance',
    summary:
        'Native Android file manager for browsing and organising files and '
        'folders, with detailed metadata, favourites, a recycle bin and FTP '
        'network access.',
    tech: ['Android', 'FTP'],
  ),
  Project(
    title: 'Malabes',
    category: ProjectCategory.earlier,
    label: 'Freelance',
    summary:
        'Native Android e-commerce app integrated with WordPress through '
        'CiyaShop APIs, so admins manage products, colours and supported UI '
        'from the WordPress panel. Multi-language.',
    tech: ['Android', 'WordPress', 'CiyaShop API'],
  ),
  Project(
    title: 'HMDH Academy',
    category: ProjectCategory.earlier,
    label: 'Freelance',
    summary:
        'Native Android e-learning app for professional handbag design, with '
        'video courses, course purchases, progress tracking and dynamically '
        'loaded content.',
    tech: ['Android', 'Firebase'],
  ),
  Project(
    title: 'E-Tijarat',
    category: ProjectCategory.earlier,
    label: 'SunzTech',
    summary:
        'Brings an existing web store to Android and iOS from one shared '
        'React Native codebase, integrated with its backend over RESTful '
        'JSON APIs.',
    tech: ['React Native', 'JavaScript', 'iOS', 'Android', 'REST'],
  ),
  Project(
    title: 'Algorithm Encyclopedia',
    category: ProjectCategory.earlier,
    label: 'Freelance',
    summary:
        'Offline Android reference for learning data structures and '
        'searching, sorting, greedy and dynamic programming algorithms, with '
        'no internet connection needed.',
    tech: ['Android', 'Offline-first'],
  ),
  Project(
    title: 'Location-Aware Profile Manager',
    category: ProjectCategory.earlier,
    label: 'Final Year Project',
    summary:
        'Native Android app that automatically switches device profiles, '
        'such as silent mode, Wi-Fi and Bluetooth, when you arrive at a '
        'configured location.',
    tech: ['Android', 'GPS', 'Google Maps', 'Geofencing'],
  ),
  Project(
    title: 'Smart Study Planner',
    category: ProjectCategory.earlier,
    label: 'Freelance',
    summary:
        'Native Android planner for students, teachers and lecturers to '
        'manage classes, homework and exams, stored in the cloud and '
        'accessible across devices.',
    tech: ['Android', 'Cloud Storage'],
  ),
];
