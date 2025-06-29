const express = require('express');
const router = express.Router();
const tokenAuth = require('../middlewares/tokenAuth.middleware');
const { checkTaskPermission, getUserRole } = require('../middlewares/taskAuth.middleware');
const controller = require('../controllers/task.controller');

//* Route để tạo nhiệm vụ mới (chỉ admin/owner)
router.post('/new', tokenAuth, checkTaskPermission('admin'), controller.create_task);

//* Route để cập nhật nhiệm vụ (chỉ admin/owner)
router.put('/update', tokenAuth, checkTaskPermission('admin'), controller.update_task);

//* Route để cập nhật cờ ưu tiên nhiệm vụ (chỉ admin/owner)
router.put('/update-flag', tokenAuth, checkTaskPermission('admin'), controller.update_task_flag);

//* Route để xóa nhiệm vụ (chỉ admin/owner)
router.delete('/delete', tokenAuth, checkTaskPermission('admin'), controller.delete_task);

//* Route để lấy tất cả nhiệm vụ của một dự án (bất kỳ thành viên nhóm nào)
router.post('/project', tokenAuth, controller.get_task_of_project);

//* Route để lấy thông tin nhiệm vụ theo ID nhiệm vụ (bất kỳ thành viên nhóm nào)
router.post('/info', tokenAuth, controller.get_task_information);

//* Route để cập nhật nhiệm vụ con của một nhiệm vụ (chỉ admin/owner)
router.post('/subtask', tokenAuth, checkTaskPermission('admin'), controller.update_subtask);

//* Route để gán nhiệm vụ cho thành viên (chỉ admin/owner)
router.post('/assign', tokenAuth, checkTaskPermission('admin'), controller.assign_task_to_member);

//* Route để hủy gán nhiệm vụ khỏi thành viên (chỉ admin/owner)
router.post('/unassign', tokenAuth, checkTaskPermission('admin'), controller.unassign_task);

//* Route để thành viên nhận nhiệm vụ chưa được gán (bất kỳ thành viên nhóm nào)
router.post('/take', tokenAuth, getUserRole, controller.take_task);

//* Route để cập nhật trạng thái nhiệm vụ với quyền hạn dựa trên vai trò (bất kỳ thành viên nhóm nào)
router.post('/update-status', tokenAuth, getUserRole, controller.update_task_status);

//* Route để chuyển đổi trạng thái nhiệm vụ (đã lỗi thời - sử dụng update-status thay thế)
router.post('/toggle-status', tokenAuth, controller.toggle_task_status);

//* Route để lấy thống kê nhiệm vụ của dự án (bất kỳ thành viên nhóm nào)
router.get('/statistics/:projectId', tokenAuth, controller.get_task_statistics);

module.exports = router;